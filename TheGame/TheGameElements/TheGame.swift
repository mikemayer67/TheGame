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
  static let MinUsernameLength = 6
  static let MinAliasLength    = 6
  static let MinPasswordLength = 8
  static let ResetCodeLength   = 6
  
  static let unchallangedLossInterval = (devTiming ? 15.0 : 3600.0) // may lose every hour
  static let challengedLossInterval   = (devTiming ?  5.0 :   60.0) // may lose one minute after opponent loses
  static let pokeInterval             = (devTiming ?  5.0 :   60.0) // may poke once per minute
  
  // From http://emailregex.com
  static let emailRegex = #"""
    (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
    """#
}

protocol TheGameErrorHandler
{
  func failedConnection(_ theGame:TheGame)
  func internalError(_ theGame:TheGame, error:String, file:String, function:String)
}

protocol TheGameDelegate
{
  func handleUpdates(_ theGame:TheGame)
  func handle(_ theGame:TheGame, notificationsEnabled:Bool)
}

class TheGame : NSObject
{
  static let shared   = TheGame()
  static let server   = GameServer()
  
  var errorDelegate  : TheGameErrorHandler?
  var delegate       : TheGameDelegate?
  var viewController : UIViewController?
  
  var notificationsEnabled : Bool? = nil
    
  var me : LocalPlayer? = nil
  {
    didSet {
      opponents.removeAll()
      if me != nil {
        Defaults.hasResetSalt = false
        loadOpponents()
      }
    }
  }
  
  private(set) var opponents = [Opponent]()
  
  private(set) var nextLossTimer : Timer?

  override init()
  {
    super.init()
    
    NotificationCenter.default.addObserver(
      forName: .newDeviceToken,
      object: nil,
      queue: .main) {
        (notification) in
        guard let me = self.me else { return }
        
        if let userInfo = notification.userInfo,
          let token = userInfo["token"] as? String
        {
          TheGame.server.setDeviceToken(userkey: me.userkey, deviceToken: token) {_ in }
        } else {
          TheGame.server.clearDeviceToken(userkey: me.userkey) { _ in }
        }
    }
  }
}

// MARK:- Opponents

extension TheGame
{
  private func loadOpponents()
  {
    opponents.removeAll()
    guard let me = me else { return }
        
    TheGame.server.lookupOpponents(userkey: me.userkey) { (query) in
      
      switch query.status!
      {
      case .FailedToConnect:
        failedToConnectToServer()
      case .Success(let data):
        if let matchData = data?[QueryKey.Matches] as? [NSDictionary] {
          self.loadOpponents(matchData)
        } else {
          self.errorDelegate?.internalError(self, error: "Missing match data", file: #file, function: #function)
        }
      default:
        self.errorDelegate?.internalError( self,
          error: query.internalError ?? "Unknown Error",
          file: #file, function: #function
        )
      }
    }
  }
  
  func loadOpponents(_ matchData:[NSDictionary])
  {
    for match in matchData
    {
      guard let t = match[QueryKey.MatchStart] as? Double,
        let matchID = match[QueryKey.MatchID] as? Int
      else {
        errorDelegate?.internalError(
          self,
          error: "Missing match_data (\(match))",
          file: #file, function: #function)
        continue
      }
      let matchStart = GameTime(networktime: t)
      
      var lastLoss : GameTime?
      if let t = match[QueryKey.LastLoss] as? Double,
        t > 0.0
      {
        lastLoss = GameTime(networktime: t)
      }
      
      let name = match[QueryKey.Name] as? String
      if let fbid = match[QueryKey.FBID] as? String
      {
        loadOpponent(fbid, matchID: matchID, matchStart:matchStart, lastLoss:lastLoss, name:name)
      }
      else if let name = name
      {
        self.opponents.append(
          Opponent(name: name, matchID: matchID, matchStart: matchStart, lastLoss: lastLoss)
        )
      }
      else
      {
        errorDelegate?.internalError(
          self,
          error: "Missing name or fbid {\(match)}",
          file: #file, function: #function)
      }
    }
    
    opponents.sort()
    delegate?.handleUpdates(self)
  }
  
  func loadOpponent(_ fbid:String, matchID:Int, matchStart:GameTime, lastLoss:GameTime?, name:String?)
  {
    let request = GraphRequest(graphPath: fbid, parameters: ["fields":"name,picture"])
    
    var opponent : Opponent? = nil
    
    request.start { (_, result, error) in
      if error == nil,
        let fbResult = result as? NSDictionary,
        let name     = fbResult["name"] as? String
      {
        var pictureURL : String?
        if let picture = fbResult["picture"] as? NSDictionary,
          let data = picture["data"] as? NSDictionary,
          let url = data["url"] as? String
        {
          pictureURL = url
        }
                
        opponent = Opponent(facebook: FacebookInfo(fbid:fbid, name:name, picture: pictureURL),
                            matchID: matchID,
                            matchStart: matchStart,
                            lastLoss: lastLoss)
      }
      else if let name = name
      {
        opponent = Opponent(name: name, matchID: matchID, matchStart: matchStart, lastLoss: lastLoss)
      }
           
      if let opponent = opponent
      {
        self.opponents.append( opponent )
        self.opponents.sort()
        self.delegate?.handleUpdates(self)
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
    
    if let t = nextLossTimer {
      t.invalidate()
      nextLossTimer = nil
    }
      
    if let delegate = delegate
    {
      let nextLoss = nextAllowableLoss
      if nextAllowableLoss > now {
        nextLossTimer = Timer.scheduledTimer(withTimeInterval: nextLoss - now, repeats: false) { _ in
          delegate.handleUpdates(self)
          self.nextLossTimer = nil
        }
      }
      delegate.handleUpdates(self)
    }
  }
  
  var nextAllowableLoss : GameTime
  {
    if let localPlayer = me, let lastLoss = localPlayer.lastLoss
    {
      for opponent in opponents
      {
        if opponent.lost(after:lastLoss) {
          return lastLoss.offset(by: K.challengedLossInterval)
        }
      }
      return lastLoss.offset(by: K.unchallangedLossInterval)
    }
    return GameTime(networktime: 0.0)
  }
}

// MARK:- TableView Delegates

extension TheGame : UITableViewDelegate, UITableViewDataSource
{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return opponents.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "opponentCell", for: indexPath)
    
    let lastLoss = me?.lastLoss
    
    cell.backgroundColor=UIColor.systemBackground
        
    if let opponent = opponents[safe:indexPath.row]
    {
      cell.textLabel?.text = opponent.name
      cell.detailTextLabel?.text = opponent.lastLossString
      if let iv = cell.imageView
      {
        iv.image = opponent.icon
        iv.layer.cornerRadius = 8.0
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 1.0
        iv.layer.masksToBounds = true
      }
      
      let layer = cell.contentView.layer
      layer.cornerRadius = 15.0
      layer.borderColor = UIColor.black.cgColor
      layer.borderWidth = 1.0
      
      cell.contentView.backgroundColor =
        ( opponent.lost(after: lastLoss) ? UIColor(named: "losingColor") : UIColor(named:"winningColor") )
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
    let drop = UIContextualAction(style: .normal, title: "Drop") {
      (action, view, completion) in
      self.dropOpponent(opponent: self.opponents[indexPath.row])
      completion(true)
    }
    drop.image = #imageLiteral(resourceName: "icons8-unfriend")
    drop.backgroundColor = UIColor.systemBackground
    return UISwipeActionsConfiguration(actions: [drop])
  }
  
  func tableView(_ tableView: UITableView,
                 leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
  {
    let poke = UIContextualAction(style: .normal, title: "Poke") {
      (action, view, completion) in
      self.pokeOpponent(opponent: self.opponents[indexPath.row])
      completion(true)
    }
    poke.image = #imageLiteral(resourceName: "icons8-poke_friend")
    poke.backgroundColor = UIColor.systemBackground
    return UISwipeActionsConfiguration(actions: [poke])
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
      
      if let notificationsEnabled = self.notificationsEnabled,
        notificationsEnabled == granted
      { return }

      self.notificationsEnabled = granted

      if let me = self.me
      {
        if granted {
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
        }
        else
        {
          TheGame.server.clearDeviceToken(userkey: me.userkey) { _ in }
        }
      }

      self.delegate?.handle(self, notificationsEnabled: granted)
    }
  }
  
  func pokeOpponent(opponent:Opponent)
  {
    guard let me = me else { return }
    
    let now = GameTime()
    if let lastPoke = opponent.lastPoke
    {
      if now < lastPoke.offset(by: K.pokeInterval)
      {
        viewController?.infoPopup(
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
        self.viewController?.infoPopup(
          title:"👍 Nice",
          message:"You have poked \(opponent.name)"
        )
      case .QueryFailure(GameQuery.Status.InvalidOpponent, _):
        self.viewController?.infoPopup(
          title: "😢 Too Late",
          message: "\(opponent.name) is no longer an opponent"
        )
      case .QueryFailure(GameQuery.Status.NotificationFailure, _):
        self.viewController?.infoPopup(
          title: "🙉 Nope",
          message: "\(opponent.name) has disabled notification"
        )
      default:
        self.errorDelegate?.internalError( self,
          error: query.internalError ?? "Unknown Error",
          file: #file, function: #function
        )
      }
    }
  }
  
  func dropOpponent(opponent:Opponent)
  {
    guard let me = me             else { return }
    guard let vc = viewController else { return }
    
    vc.confirmationPopup(
      title: "⚠️ Are you sure?",
      message: "This will end your competition with \(opponent.name)",
      ok: "Yes",
      cancel: "No",
      animated: true) {
        (response) in
        if response
        {
          vc.confirmationPopup(
            title: "💬 Let them know?",
            message: "This will send a a notification to \(opponent.name) to let them know you have dropped them",
            ok: "Yes",
            cancel: "No",
            animated: true) {
              (notify) in
              self.dropOpponent(userkey:me.userkey, opponent:opponent, notify:notify)
          }
        }
    }
  }
  
  private func dropOpponent(userkey:String, opponent:Opponent, notify:Bool)
  {
    TheGame.server.dropOpponent(userkey:userkey, matchID:opponent.matchID, notify:notify)
    {
      (query) in
      switch query.status
      {
      case .FailedToConnect:
        failedToConnectToServer()
      case .Success(let data):
        if notify
        {
          let notified = data?[QueryKey.Notify] as? Int ?? 0
          if notified == 1
          {
            self.viewController?.infoPopup(
              title: "👍 Done",
              message: "\(opponent.name) has been notified that the competition is over."
            )
          }
          else
          {
            self.viewController?.infoPopup(
              title: "🙉 Oh Well...",
              message: "\(opponent.name) has disabled notification and was therefore not notified you dropped them."
            )
          }
        }
        
        self.opponents = self.opponents.filter { $0.matchID != opponent.matchID }
        self.delegate?.handleUpdates(self)
        
      case .QueryFailure(GameQuery.Status.InvalidOpponent, _):
        break
      case .QueryFailure(GameQuery.Status.Failed, _):
        self.viewController?.infoPopup(
          title: "🤔 Interesting",
          message: "For some reason, could not drop \(opponent.name)"
        )
      default:
        self.errorDelegate?.internalError( self,
                                           error: query.internalError ?? "Unknown Error",
                                           file: #file, function: #function
        )
      }
    }
  }
      
}
