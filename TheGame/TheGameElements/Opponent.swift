//
//  Opponent.swift
//  TheGame
//
//  Created by Mike Mayer on 6/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class Opponent : TheGamePlayer, Comparable
{
  var matchStart : GameTime? = nil
  
  init?(_ data:NSDictionary)
  {
    if let name = data["name"] as? String
    {
      super.init(name: name)
    }
    else if let fbid = data["fbid"] as? String
    {
      super.init(facebook: fb)
    }
    else
    {
      return nil
    }
    
    if let t = data["match_start"] as? TimeInterval { self.matchStart = GameTime(networktime: t) }
    if let t = data["last_loss"]   as? TimeInterval { self.lastLoss   = GameTime(networktime: t) }
  }
    
  static func < (lhs: Opponent, rhs: Opponent) -> Bool
  {
    return rhs.lost(after: lhs.lastLoss)
  }
  
  static func == (lhs: Opponent, rhs: Opponent) -> Bool
  {
    if lhs.lost(after:rhs) { return false }
    if rhs.lost(after:lhs) { return false }
    return true
  }
}
