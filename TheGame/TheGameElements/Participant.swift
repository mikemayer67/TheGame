//
//  Participant.swift
//  TheGame
//
//  Created by Mike Mayer on 7/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

protocol Participant
{
  var name           : String    { get }
  var icon           : UIImage?  { get }
  var lastLoss       : GameTime? { get set }
  var lastLossString : String    { get }
  
  func lost(after time:GameTime?) -> Bool
  func lost(after other:Participant) -> Bool
}

extension Participant
{
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
