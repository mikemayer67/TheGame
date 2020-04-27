//
//  TheGamePlayer.swift
//  TheGame
//
//  Created by Mike Mayer on 4/26/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class TheGamePlayer : GamePlayer
{
  override init(key: String, name: String, gameData: HashData? = nil) {
    super.init(key: key, name: name, gameData: gameData ?? HashData())
  }
  
  override init(key: String, facebook: FacebookInfo, gameData: HashData? = nil) {
    super.init(key: key, facebook: facebook, gameData: gameData ?? HashData() )
  }
  
  var lastLoss : GameTime? {
    get {
      var rval : GameTime?
      if let t = gameData!.getDouble("last_loss") { rval = GameTime(networktime: t) }
      return rval
    }
    set {
      gameData!.set(value: newValue?.networktime, for:"last_loss")
    }
  }
  
  var lastLossString : String
  {
    if let s = lastLoss?.string { return "Last Loss: \(s)" }
    else                        { return "No loss yet"     }
  }
  
  func lost(after time:GameTime?) -> Bool
  {
    guard let lastLoss = lastLoss else { return false }
    guard let time     = time     else { return true  }
    return lastLoss > time
  }
  
  func lost(after other:TheGamePlayer) -> Bool
  {
    return lost(after:other.lastLoss)
  }
}

class Opponent : TheGamePlayer, Comparable
{
  var matchStart : GameTime?
  
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

class DebugOpponent : Opponent  // @@@ REMOVE
{
  static var nextID : Int = 1
  
  let lossFrequency : Double
  
  init(_ name:String, gameAge:Double /*days*/, lossFrequency:TimeInterval, lost:TimeInterval? = nil)
  {
    DebugOpponent.nextID = DebugOpponent.nextID + 1

    self.lossFrequency = lossFrequency

    super.init(key: "DebugOpponent-\(DebugOpponent.nextID)", name: name)
    
    let now = GameTime()

    if let lost = lost { self.lastLoss = now.offset(by: -1.0 * lost) }
    
    self.matchStart = now.offset(by: -86400.0 * gameAge)
  }
}
