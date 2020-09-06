//
//  Participants.swift
//  TheGame
//
//  Created by Mike Mayer on 7/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class Participant
{
  var lastLoss : GameTime?
  
  init(lastLoss : GameTime? = nil)
  {
    self.lastLoss = lastLoss
  }
  
  var lastLossString : String
  {
    if let t = lastLoss?.string { return t }
    else                        { return "No loss yet" }
  }
  
  func lost(after time:GameTime?) -> Bool
  {
    guard let lastLoss = lastLoss else { return false }
    guard let time     = time     else { return true  }
    return lastLoss > time
  }
  
  func lost(after other:Participant) -> Bool
  {
    return lost(after:other.lastLoss)
  }
}
