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
  private static var _clockOffset : TimeInterval?
  private static var  clockOffset : TimeInterval
  {
    get {
      if GameTime._clockOffset == nil, let serverTime = TheGame.server.time
      {
        let now = Date().timeIntervalSince1970 as TimeInterval
        GameTime._clockOffset = TimeInterval(serverTime) - now
      }
      return GameTime._clockOffset ?? 0.0
    }
  }
  
  private var value : TimeInterval = 0.0  // store as localtime internally
  
  init()                         { value = Date().timeIntervalSince1970 }
  init(localtime:TimeInterval)   { value = localtime }
  init(networktime:TimeInterval) { value = networktime - GameTime.clockOffset }
  
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
    get { return value + GameTime.clockOffset }
    set { value = newValue - GameTime.clockOffset }
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


//  struct WorldTimeAPI : Decodable { let unixtime : Int }
//
//  let decoder = JSONDecoder()
//
//  let url = "https://worldtimeapi.org/api/timezone/Etc/GMT"
//  guard let netTimeURL = URL(string: url) else
//  {
//    NSLog("Invalid netTimeURL: \(url)")
//    return 0.0
//  }
//
//  guard let netTimeData = try? Data(contentsOf: netTimeURL) else
//  {
//    NSLog("No response from \(url)")
//    return 0.0
//  }
//
//  guard let wmTime = try? decoder.decode(WorldTimeAPI.self, from:netTimeData) else
//  {
//    NSLog("Failed to decode unix time from response from \(url)")
//    return 0.0
//  }
