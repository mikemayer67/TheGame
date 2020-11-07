//
//  Opponent.swift
//  TheGame
//
//  Created by Mike Mayer on 6/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FacebookLogin

class Opponent : Participant, Comparable
{
  let matchID         : Int
  var name            : String
  var icon            : UIImage?
  var matchStart      : GameTime
  var lastLoss        : GameTime?
  var lastPoke        : GameTime?
  
  init(_ match : MatchData)
  {
    self.matchID    = match.id
    self.name       = match.name
    self.icon       = createIcon(for: match.name, with: match.picture)
    self.matchStart = match.start
    self.lastPoke   = nil
    
    lastLoss = match.lastLoss
  }
    
  static func < (lhs: Opponent, rhs: Opponent) -> Bool
  {
    return lhs.lost(after: rhs.lastLoss)
  }
  
  static func == (lhs: Opponent, rhs: Opponent) -> Bool
  {
    if lhs.lost(after:rhs) { return false }
    if rhs.lost(after:lhs) { return false }
    return true
  }
}
