//
//  CommonUtil.swift
//  TheGame
//
//  Created by Mike Mayer on 2/7/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

let Defaults = UserDefaults.standard

extension Array
{
  public subscript(safe index: Index) -> Iterator.Element? {
    guard index >= 0         else { return nil }
    guard index < self.count else { return nil }
    return self[index]
  }
}

extension Date
{
  /**
   Number of seconds since 01-Jan-1970 00:00:00
   */
  var unixtime: Double { return self.timeIntervalSince1970  }
  
  static func -(lhs:Date,rhs:Date) -> TimeInterval
  { return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970 }
}

typealias HashData = Dictionary<String,Any>

extension HashData
{
  func getInt    (_ key:String) -> Int?    { return self[key] as? Int    }
  func getDouble (_ key:String) -> Double? { return self[key] as? Double }
  func getBool   (_ key:String) -> Bool?   { return self[key] as? Bool   }
  func getString (_ key:String) -> String? { return self[key] as? String }
  
  mutating func set(value:Any?, for key:String)
  {
    if let v = value { self[key] = v }
    else { self.removeValue(forKey: key) }
  }
}

func debug(_ args:Any...)
{
  print("DEBUG::",args)
}

func track(_ args:Any...)
{
  print("DEBUG::TRACK - ",args)
}


