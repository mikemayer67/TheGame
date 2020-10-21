//
//  TheGame.swift
//  TheGame
//
//  Created by Mike Mayer on 4/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

let devTiming = Bundle.main.object(forInfoDictionaryKey: "DevTiming") as? Bool ?? false

enum K
{
  static let MinNameLength        = 6
  static let RecoveryCodeLength   = 8
  static let TransferCodeLength   = 8
  
  static let reloadOpponentsInterval  = (devTiming ? 15.0 :  120.0) // check for updates every 2 minutes
  static let unchallangedLossInterval = (devTiming ? 15.0 : 3600.0) // may lose every hour
  static let challengedLossInterval   = (devTiming ?  5.0 :   60.0) // may lose one minute after opponent loses
  static let pokeInterval             = (devTiming ?  5.0 :   60.0) // may poke once per minute
  
  // From http://emailregex.com
  static let emailRegex = #"""
    (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
    """#
}

enum RemoteNotificationFlavor : String
{
  case poke = "poke"
  case loss = "loss"
}

class TheGame : NSObject
{
  static let shared = TheGame()
  static let server = GameServer()
  
  weak var vc : GameViewController?
  
  private(set) var opponents = Opponents()
  
  private(set) var nextLossTimer : Timer?
  private(set) var reloadOpponentsTimer : Timer?
  
  private(set) var notificationsEnabled : Bool? = nil
  {
    didSet { if notificationsEnabled != oldValue { updateReloadOpponentsTimer() } }
  }
  
  private(set) var 
      
  var me : LocalPlayer? = nil
  {
    didSet {
      opponents.dropAll()
      if me != nil {
        Defaults.hasRecoveryCode = false
        updateOpponents()
      }
    }
  }

  override init()
  {
    super.init()
    
    NotificationCenter.default.addObserver(forName:.newDeviceToken, object:nil, queue:.main) {
      (notification) in
      
      guard let me = self.me else { return }
      
      if let userInfo = notification.userInfo, let token = userInfo["token"] as? String {
        debug("newDeviceToken: \(token)")
        TheGame.server.setDeviceToken(userkey: me.userkey, deviceToken: token) {_ in }
      } else {
        debug("clear device token")
        TheGame.server.clearDeviceToken(userkey: me.userkey) { _ in }
      }
    }
    
    NotificationCenter.default.addObserver(forName:.remoteNotification, object:nil, queue:.main) {
      (notification) in
      if let userInfo = notification.userInfo,  let content = userInfo["content"] as? UNNotificationContent
      {  self.handleNotification(content) }
    }
  }
}

// MARK:- Opponents

extension TheGame
{
  func updateReloadOpponentsTimer()
  {
    let notificationsEnabled = self.notificationsEnabled ?? false
    
    if notificationsEnabled, reloadOpponentsTimer != nil
    {
      DispatchQueue.main.async {
        self.reloadOpponentsTimer!.invalidate()
        self.reloadOpponentsTimer = nil
      }
    }
    else if notificationsEnabled == false, reloadOpponentsTimer == nil
    {
      DispatchQueue.main.async {
        self.reloadOpponentsTimer =
          Timer.scheduledTimer( withTimeInterval: K.reloadOpponentsInterval, repeats: true)
          { _ in
            self.updateOpponents()
          }
      }
    }
  }
  
  
  private func updateOpponents()
  {
    debug("upateOpponents()")
    guard let me = me else { return }
        
    TheGame.server.lookupOpponents(userkey: me.userkey) { (query) in
      
      switch query.status!
      {
      case .FailedToConnect:
        failedToConnectToServer()
      case .Success(let data):
        if let matchData = MatchSet(data) {
          self.updateOpponents(matchData)
        } else {
          self.vc?.internalError("Missing match data", file: #file, function: #function)
        }
      default:
        self.vc?.internalError( query.internalError ?? "Unknown Error", file: #file, function: #function )
      }
    }
  }
  
  private func updateOpponents(_ matches:MatchSet)
  {
    let oldOrder = opponents.order
    var newMatchIDs = Set<Int>()
    var newFBIDs = Dictionary<Int,String>()   // matchID, FBID
          
    for match in matches
    {
      newMatchIDs.insert(match.id)
      if let opponent = opponents.find(matchID: match.id)
      {
        opponent.lastLoss = match.lastLoss
      }
      else
      {
        opponents.add( Opponent(match) )
        if let fbid = match.fbid { newFBIDs[match.id] = fbid }
      }
    }
    
    for id in Set(oldOrder.keys).subtracting(newMatchIDs) { opponents.drop(matchID: id) }
    
    opponents.sort()
    updateOpponentTable(from: oldOrder, to: opponents.order)
    vc?.update()
    
    for (matchID,fbid) in newFBIDs { updateFBInfo(matchID: matchID, fbid: fbid) }
  }
  
  func updateFBInfo(matchID:Int, fbid:String)
  {
    guard
      AccessToken.current != nil,
      let opponent = opponents.find(matchID: matchID)
    else { return }
          
    let request = GraphRequest(graphPath: fbid, parameters: ["fields":"name,picture"])
      
    request.start { (_, result, error) in
      if error == nil,
         let fbResult = result as? NSDictionary,
         let name     = fbResult["name"] as? String
      {
        var pictureURL : String?
        
        if let picture = fbResult["picture"] as? NSDictionary,
           let data    = picture["data"] as? NSDictionary,
           let url     = data["url"] as? String
        { pictureURL = url }
        
        opponent.update(name: name, pictureUrl: pictureURL)
        self.updateOpponentTable(for: opponent)
      }
    }
  }
}

// MARK:- Last Loss

extension TheGame
{
  var lastLoss : GameTime? { me?.lastLoss }
  var allowedToLose : Bool { GameTime() > nextAllowableLoss }
   
  func iLost() -> Void
  {
    let now = GameTime()
    me?.lastLoss = now   // me updates the game server
    
    updateOpponents()
    
    if let t = nextLossTimer {
      t.invalidate()
      nextLossTimer = nil
    }
      
    if let vc = vc
    {
      let nextLoss = nextAllowableLoss
      if nextAllowableLoss > now {
        nextLossTimer = Timer.scheduledTimer(withTimeInterval: nextLoss - now, repeats: false) { _ in
          vc.update()
          self.nextLossTimer = nil
        }
      }
      vc.update()
    }
  }
  
  var nextAllowableLoss : GameTime
  {
    if let localPlayer = me, let lastLoss = localPlayer.lastLoss
    {
      if opponents.hasLoss(after:lastLoss)
      {
        return lastLoss.offset(by: K.challengedLossInterval)
      }
      return lastLoss.offset(by: K.unchallangedLossInterval)
    }
    return GameTime(networktime: 0.0)
  }
}

// MARK:- TableView Support (includeing delegates)

extension TheGame : UITableViewDelegate, UITableViewDataSource
{
  func updateOpponentTable(from old:Dictionary<Int,Int>, to new:Dictionary<Int,Int>)
  {
    guard let vc = vc, let ot = vc.opponentTable else { return }
    
    let oldIDs = Set( old.keys )
    let newIDs = Set( new.keys )
    
    let remove = Array( oldIDs.subtracting(newIDs).map( {IndexPath(row: old[$0]!, section: 0)} ) )
    let insert = Array( newIDs.subtracting(oldIDs).map( {IndexPath(row: new[$0]!, section: 0)} ) )
    
    ot.beginUpdates()
    
    ot.deleteRows(at: remove, with: .fade)
    ot.insertRows(at: insert, with: .fade)
    
    for matchID in oldIDs.intersection(newIDs) {
      ot.moveRow(
        at: IndexPath(row: old[matchID]!, section: 0),
        to: IndexPath(row: new[matchID]!, section: 0))
    }
    
    ot.endUpdates()
    
    updateOpponentTable()
  }
  
  func updateOpponentTable()
  {
    guard let vc = vc, let ot = vc.opponentTable else { return }
    for (row,opponent) in opponents.opponents.enumerated()
    {
      if let cell = ot.cellForRow(at:  IndexPath(row: row, section: 0))
      {
        updateOpponentTable(cell:cell, opponent: opponent)
      }
    }
  }
  
  func updateOpponentTable(for opponent:Opponent)
  {
    guard let vc = vc, let ot = vc.opponentTable else { return }
    
   if let row = opponents.row(opponent: opponent),
      let cell = ot.cellForRow(at:  IndexPath(row: row, section: 0))
    {
      updateOpponentTable(cell: cell, opponent: opponent)
    }
  }
  
  func updateOpponentTable(cell:UITableViewCell, opponent:Opponent)
  {
    cell.textLabel?.text       = opponent.name
    cell.detailTextLabel?.text = opponent.lastLossString
    cell.imageView?.image      = opponent.icon
    
    if opponent.lost(after: me?.lastLoss) {
      cell.contentView.backgroundColor = UIColor(named: "losingColor")
    }
    else {
      cell.contentView.backgroundColor = UIColor(named: "winningColor")
    }
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return opponents.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "opponentCell", for: indexPath)
        
    cell.backgroundColor=UIColor.systemBackground
        
    if let opponent = opponents[indexPath.row]
    {
      if let iv = cell.imageView
      {
        iv.layer.cornerRadius = 8.0
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 1.0
        iv.layer.masksToBounds = true
      }
      
      let layer = cell.contentView.layer
      layer.cornerRadius = 15.0
      layer.borderColor = UIColor.black.cgColor
      layer.borderWidth = 1.0
      
      updateOpponentTable(cell: cell, opponent: opponent)
    }
    else
    {
      cell.textLabel?.text = "Coding Error"
      cell.detailTextLabel?.text = "oops"
      cell.imageView?.image = UIImage(named: "bug")
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
  {
    guard let opponent = opponents[indexPath.row] else { return nil }
    
    let drop = UIContextualAction(style: .normal, title: "Drop") {
      (action, view, completion) in
      self.dropOpponent(opponent: opponent)
      completion(true)
    }
    drop.image = #imageLiteral(resourceName: "icons8-unfriend")
    drop.backgroundColor = UIColor.systemBackground
    return UISwipeActionsConfiguration(actions: [drop])
  }
  
  func tableView(_ tableView: UITableView,
                 leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
  {
    guard let opponent = opponents[indexPath.row] else { return nil }
    
    let poke = UIContextualAction(style: .normal, title: "Poke") {
      (action, view, completion) in
      self.pokeOpponent(opponent: opponent)
      completion(true)
    }
    poke.image = #imageLiteral(resourceName: "icons8-poke_friend")
    poke.backgroundColor = UIColor.systemBackground
    return UISwipeActionsConfiguration(actions: [poke])
  }
}

// MARK:- Opponents

extension TheGame
{
  func dropOpponent(opponent:Opponent)
  {
    guard let me = me, let vc = vc else { return }
    
    vc.confirmationPopup(
      title: "⚠️ Are you sure?",
      message: "This will end your competition with \(opponent.name)",
      ok: "Yes", cancel: "No", animated: true)
    {
      (response) in
      guard response else { return }
      
      vc.confirmationPopup(
        title: "💬 Let them know?",
        message: "This will send a a notification to \(opponent.name) to let them know you have dropped them",
        ok: "Yes", cancel: "No", animated: true)
      {
        (notify) in
        TheGame.server.dropOpponent(userkey:me.userkey, matchID:opponent.matchID, notify:notify)
        {
          (query) in
          switch query.status
          {
          case .Success(let data):
            if notify {
              let notified = ( data?[QueryKey.Notify] as? Int == 1 )
              let title = ( notified ? "👍 Done" : "🙉 Oh Well..." )
              let message = ( notified
                                ? "has been notified that the competition is over."
                                : "has disabled notification and was therefore not notified you dropped them." )
              vc.infoPopup(title: title, message: "\(opponent.name) \(message)")
            }
            self.updateOpponents()
            
          case .FailedToConnect: failedToConnectToServer()
          case .QueryFailure(GameQuery.Status.InvalidOpponent, _): break
          default: self.vc?.internalError( query.internalError ?? "Unknown Error", file: #file, function: #function )
          }
        }
      }
    }
  }
  
}

// MARK:- Notifications

extension TheGame
{
  func updateNotificationState()
  {
    UNUserNotificationCenter.current().getNotificationSettings() {
      settings in
      
      let granted = settings.authorizationStatus == UNAuthorizationStatus.authorized
      
      // only send status to delegate if the value of notificationEnabled is changing
      // (this does not include the initial setting of the value)
      
      if self.notificationsEnabled != nil, self.notificationsEnabled == granted { return }
      
      self.notificationsEnabled = granted

      if let me = self.me {
        if granted {
          DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        }  else {
          TheGame.server.clearDeviceToken(userkey: me.userkey) { _ in }
        }
      }

      self.vc?.handle(notificationsEnabled: granted)
    }
  }
  
  func pokeOpponent(opponent:Opponent)
  {
    guard let me = me, let vc = vc else { return }
    
    let now = GameTime()
    if let lastPoke = opponent.lastPoke
    {
      if now < lastPoke.offset(by: K.pokeInterval)
      {
        vc.infoPopup(
          title:"🛑 Woah There!",
          message:"Too soon to try to poke \(opponent.name) again"
        )
        return
      }
    }
    opponent.lastPoke = now

    TheGame.server.pokeOpponent(userkey: me.userkey, matchID: opponent.matchID)
    {
      (query) in
      switch query.status!
      {
      case .FailedToConnect:
        failedToConnectToServer()
      case .Success:
        vc.infoPopup(
          title:"👍 Nice",
          message:"You have poked \(opponent.name)"
        )
      case .QueryFailure(GameQuery.Status.InvalidOpponent, _):
        vc.infoPopup(
          title: "😢 Too Late",
          message: "\(opponent.name) is no longer an opponent"
        )
      case .QueryFailure(GameQuery.Status.NotificationFailure, _):
        vc.infoPopup(
          title: "🙉 Nope",
          message: "\(opponent.name) has disabled notification"
        )
      default:
        self.vc?.internalError( query.internalError ?? "Unknown Error", file: #file, function: #function )
      }
    }
  }
  
  private func handleNotification( _ content : UNNotificationContent )
  {
    guard let f = content.userInfo["flavor"] as? String,
          let flavor = RemoteNotificationFlavor(rawValue:f)
          else { return }
    
    if let vc = self.vc
    {
      switch flavor
      {
      case .poke:
        let title = "👉 You've been Poked 👈"
        let message : String = {
          if let range = content.title.range(of: "^.*poked by", options: .regularExpression) {
            return content.title.replacingCharacters(in: range, with: "You can thank")
          }
          return title
        }()
        vc.infoPopup( title: title, message: message )
        
      case .loss:
        let title = "😖 Oh man..."
        let message : String = {
          if let range = title.range(of: "TheGame") {
            return content.title.replacingCharacters(in: range, with: "the game")
          }
          return content.title
        }()
        vc.infoPopup( title:title , message: message )
      }
    }
    
    updateOpponents()
  }
      
}
