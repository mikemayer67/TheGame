//
//  GameClock.swift
//  TheGame
//
//  Created by Mike Mayer on 2/3/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class GameClock
{
  static let instance = GameClock()
  
  private(set) var offset : TimeInterval = 0.0
  
  class func gametime(localtime:Date) -> TimeInterval {
    return localtime.timeIntervalSince1970 - GameClock.instance.offset
  }
  
  class func localtime(gametime:TimeInterval) -> Date {
    Date(timeIntervalSince1970: gametime + GameClock.instance.offset)
  }
  
  class func intervalUntil(gametime:TimeInterval) -> TimeInterval {
    return (gametime + GameClock.instance.offset) - Double(Date().unixtime)
  }
  
  fileprivate init()
  {
    struct WorldTimeAPI : Decodable { let unixtime : Int }
    
    let decoder = JSONDecoder()
    
    let url = "https://worldtimeapi.org/api/timezone/Etc/GMT"
    guard let netTimeURL = URL(string: url) else
    {
      NSLog("Invalid netTimeURL: \(url)")
      return
    }
    
    guard let netTimeData = try? Data(contentsOf: netTimeURL) else
    {
      NSLog("No response from \(url)")
      return
    }
    
    guard let wmTime = try? decoder.decode(WorldTimeAPI.self, from:netTimeData) else
    {
      NSLog("Failed to decode unix time from response from \(url)")
      return
    }
        
    let now = Date()
    offset =  TimeInterval(wmTime.unixtime) - now.timeIntervalSince1970
    NSLog("GameClock offset: \(offset)")
  }
}
