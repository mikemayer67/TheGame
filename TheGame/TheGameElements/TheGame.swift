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
}

class TheGame : NSObject
{
  static let shared   = TheGame()
  static let server   = GameServer()
  
  var errorDelegate  : TheGameErrorHandler?
  var delegate       : TheGameDelegate?
    
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
    me?.lastLoss = now
    updateLossTimer()
    delegate?.handleUpdates(self)
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
  
  func updateLossTimer() -> Void
  {
    if let t = nextLossTimer {
      t.invalidate()
      nextLossTimer = nil
    }
    
    guard let delegate = delegate else { return }
    
    let now = GameTime()
    let nextLoss = nextAllowableLoss
    if nextLoss > now {
      nextLossTimer = Timer.scheduledTimer(withTimeInterval: nextLoss - now, repeats: false) { _ in
        delegate.handleUpdates(self)
        self.nextLossTimer = nil
      }
    }
    else
    {
      delegate.handleUpdates(self)
    }
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
      cell.imageView?.image = opponent.icon
      
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
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
  {
    let unfriend = UIContextualAction(style: .normal, title: "Unfriend") { (action, view, completion) in
      track("unfriend opponent at row: \(indexPath)")
    }
    unfriend.image = #imageLiteral(resourceName: "icons8-unfriend")
    unfriend.backgroundColor = UIColor.systemBackground
    return UISwipeActionsConfiguration(actions: [unfriend])
  }
  
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
  {
    let poke = UIContextualAction(style: .normal, title: "Poke") { (action, view, completion) in
      track("poke opponent at row: \(indexPath)")
    }
    poke.image = #imageLiteral(resourceName: "icons8-poke_friend")
    poke.backgroundColor = UIColor.systemBackground
    return UISwipeActionsConfiguration(actions: [poke])
  }
}

// MARK:- REMOVE
extension TheGame
{
  func reset_REMOVE()
  {
    me?.lastLoss = nil
    updateLossTimer()
    delegate?.handleUpdates(self)
  }
  
  func opponentLost_REMOVE(_ tag:Int)
  {
    if let opponent = opponents[safe:tag]
    {
      opponent.lastLoss = GameTime()
      updateLossTimer()
      delegate?.handleUpdates(self)
    }
  }
}
