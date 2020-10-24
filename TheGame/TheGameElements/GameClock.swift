//
//  GameClock.swift
//  TheGame
//
//  Created by Mike Mayer on 2/3/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

struct GameTime
{
  private var value : TimeInterval = 0.0  // store as localtime internally
  
  init()                         { value = Date().timeIntervalSince1970 }
  init(localtime:TimeInterval)   { value = localtime }
  init(networktime:TimeInterval) { value = networktime - TheGame.server.clockOffset }
  
  var string : String
  {
    DateFormatter.localizedString(from: self.date, dateStyle: .medium, timeStyle: .medium)
  }
  
  var localtime : TimeInterval
  {
    get { return value }
    set { value = newValue }
  }
  
  var networktime : TimeInterval
  {
    get { return value + TheGame.server.clockOffset }
    set { value = newValue - TheGame.server.clockOffset }
  }
  
  var date : Date  // localtime
  {
    get { return Date(timeIntervalSince1970: value) }
    set { value = newValue.timeIntervalSince1970  }
  }
  
  func offset(by offset:TimeInterval) -> GameTime
  {
    return GameTime(localtime: value + offset)
  }
  
  static func > (lhs:GameTime, rhs:GameTime) -> Bool
  {
    return lhs.value > rhs.value
  }
  
  static func < (lhs:GameTime, rhs:GameTime) -> Bool
  {
    return lhs.value < rhs.value
  }
  
  static func == (lhs:GameTime, rhs:GameTime) -> Bool
  {
    return lhs.value == rhs.value
  }
  
  static func - (lhs:GameTime, rhs:GameTime) -> TimeInterval
  {
    return lhs.value - rhs.value
  }
}
