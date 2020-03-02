//
//  GameClock.swift
//  TheGame
//
//  Created by Mike Mayer on 2/3/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

fileprivate let clockOffset = calcOffset()

class GameTime
{
  private var value : TimeInterval = 0.0  // store as localtime internally
  
  init()                         { value = Date().timeIntervalSince1970 }
  init(localtime:TimeInterval)   { value = localtime }
  init(networktime:TimeInterval) { value = networktime - clockOffset }
  
  var gameString: String { self.date.gameString }
  
  var localtime : TimeInterval
  {
    get { return value }
    set { value = newValue }
  }
  
  var networktime : TimeInterval
  {
    get { return value + clockOffset }
    set { value = newValue - clockOffset }
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
    return lhs.value > rhs.value
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


fileprivate func calcOffset() -> TimeInterval
{
  struct WorldTimeAPI : Decodable { let unixtime : Int }
  
  let decoder = JSONDecoder()
  
  let url = "https://worldtimeapi.org/api/timezone/Etc/GMT"
  guard let netTimeURL = URL(string: url) else
  {
    NSLog("Invalid netTimeURL: \(url)")
    return 0.0
  }
  
  guard let netTimeData = try? Data(contentsOf: netTimeURL) else
  {
    NSLog("No response from \(url)")
    return 0.0
  }
  
  guard let wmTime = try? decoder.decode(WorldTimeAPI.self, from:netTimeData) else
  {
    NSLog("Failed to decode unix time from response from \(url)")
    return 0.0
  }
      
  let now = Date()
  let offset =  TimeInterval(wmTime.unixtime) - now.timeIntervalSince1970
  NSLog("GameClock offset: \(offset)")
  
  return offset
}
