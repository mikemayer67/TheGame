//
//  TheGame.swift
//  TheGame
//
//  Created by Mike Mayer on 4/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

enum K
{
  static let MinUsernameLength = 6
  static let MinAliasLength    = 6
  static let MinPasswordLength = 8
  static let ResetCodeLength   = 6
  
  // From http://emailregex.com
  static let emailRegex = #"""
    (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
    """#
}

class TheGame
{
  static let shared   = TheGame()
  static let server   = GameServer()
  
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
  
  func loadOpponents()
  {
    opponents.removeAll()
    guard let me = me else { return }
        
    TheGame.server.lookupOpponents(userkey: me.userkey) { (query) in
      switch query.status
      {
      case .FailedToConnect:
        track("delgate connection faliure")
        
      case .Success(let data):
        if let matches = data?["matches"] as? [NSDictionary]
        {
          for matchData in matches
          {
            if let opponent = Opponent(matchData) { self.opponents.append(opponent) }
          }
        }
        
      default:
        track("delegate opponent query failure")
      }
    }
  }
  
}
