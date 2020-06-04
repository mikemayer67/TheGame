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
  var matchStart : GameTime
  
  init(name:String, matchStart:GameTime, lastLoss:GameTime? = nil)
  {
    self.matchStart = matchStart
    super.init(name:name, lastLoss:lastLoss)
  }
  
  init(facebook:FacebookInfo, matchStart:GameTime, lastLoss:GameTime? = nil)
  {
    self.matchStart = matchStart
    super.init(facebook:facebook, lastLoss:lastLoss)
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
