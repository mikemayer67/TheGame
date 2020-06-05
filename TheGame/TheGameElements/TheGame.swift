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

enum K
{
  static let MinUsernameLength = 6
  static let MinAliasLength    = 6
  static let MinPasswordLength = 8
  static let ResetCodeLength   = 6
  
  static let unchallangedLossInterval = (Defaults.dev ? 15.0 : 3600.0) // may lose every hour
  static let challengedLossInterval   = (Defaults.dev ?  5.0 :   60.0) // may lose one minute after opponent loses
  
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

protocol TheGameUpdateDelegate
{
  func opponentsUpdated(_ theGame:TheGame)
}

class TheGame
{
  static let shared   = TheGame()
  static let server   = GameServer()
  
  var errorDelegate  : TheGameErrorHandler?
  var updateDelegate : TheGameUpdateDelegate?
  
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
  
  var opponents = [Opponent]()
}

// MARK:- Opponents

extension TheGame
{
  private func loadOpponents()
  {
    opponents.removeAll()
    guard let me = me else { return }
        
    TheGame.server.lookupOpponents(userkey: me.userkey) { (query) in
      
      if case .Success(let data) = query.status,
        let matchData = data?[QueryKey.Matches] as? [NSDictionary]
      {
        self.loadOpponent(matchData)
      }
      
      else if case .FailedToConnect = query.status {
        self.errorDelegate?.failedConnection(self)
      }
      else
      {
        self.errorDelegate?.internalError( self,
          error: query.internalError ?? "Unknown Error",
          file: #file, function: #function
        )
      }
    }
  }
  
  func loadOpponent(_ matchData:[NSDictionary])
  {
    for match in matchData
    {
      guard let t = (match[QueryKey.MatchStart] as? NSString)?.doubleValue else
      {
        errorDelegate?.internalError(
          self,
          error: "Missing match_data (\(match))",
          file: #file, function: #function)
        continue
      }
      let matchStart = GameTime(networktime: t)
      
      var lastLoss : GameTime?
      if let t = (match[QueryKey.LastLoss] as? NSString)?.doubleValue
      {
        lastLoss = GameTime(networktime: t)
      }
      
      if let fbid = match[QueryKey.FBID] as? String
      {
        loadOpponent(fbid, matchStart:matchStart, lastLoss:lastLoss)
      }
      else if let name = match[QueryKey.Name] as? String
      {
        self.opponents.append(
          Opponent(name: name, matchStart: matchStart, lastLoss: lastLoss)
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
    
    updateDelegate?.opponentsUpdated(self)
  }
  
  func loadOpponent(_ fbid:String, matchStart:GameTime, lastLoss:GameTime?)
  {
    let request = GraphRequest(graphPath: fbid, parameters: ["fields":"name,picture"])
    
    request.start { (_, result, error) in
      guard error == nil,
        let fbResult = result as? NSDictionary,
        let name     = fbResult["name"] as? String
        else { return }
      
      var pictureURL : String?
      if let picture = fbResult["picture"] as? NSDictionary,
        let data = picture["data"] as? NSDictionary,
        let url = data["url"] as? String
      {
        pictureURL = url
      }
      
      let fbInfo = FacebookInfo(id:fbid, name:name, picture: pictureURL)
      
      self.opponents.append(
        Opponent(facebook: fbInfo, matchStart: matchStart, lastLoss: lastLoss)
      )
      
      self.updateDelegate?.opponentsUpdated(self)
    }
  }
}
