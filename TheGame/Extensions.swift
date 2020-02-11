//
//  Extensions.swift
//  TheGame
//
//  Created by Mike Mayer on 2/7/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

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
  var lossTimeString: String
  {
    return "Last Loss: " + DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .medium)
  }
  
  var unixtime: Int
  {
    return Int(self.timeIntervalSince1970)
  }
  
  static func -(lhs:Date,rhs:Date) -> TimeInterval
  {
    return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
  }
}
