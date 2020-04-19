//
//  Player.swift
//  TheGame
//
//  Created by Mike Mayer on 2/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

struct FBUserInfo
{
  let fbid : String
  let name : String
  let picture : String?
}

class Player
{
  let key       : String
  let name      : String
  let fb        : FBUserInfo?
  
  var lastLoss  : GameTime?
  {
    didSet { debug("Add logic to handle changing lastLoss") }
  }
  
  var lastLossString : String
  {
    return lastLoss?.gameString ?? "No loss yet"
  }
  
  func lost(after time:GameTime?) -> Bool
  {
    if lastLoss == nil { return false }
    if time == nil     { return true  }
    return lastLoss! > time!
  }
  
  init(key:String, name:String, fb:FBUserInfo? = nil, lastLoss : GameTime? = nil)
  {
    self.key      = key
    self.name     = name
    self.fb       = fb
    self.lastLoss = lastLoss
  }
}
