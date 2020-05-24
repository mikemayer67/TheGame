//
//  UserDefaults_TheGame.swift
//  TheGame
//
//  Created by Mike Mayer on 4/28/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension UserDefaults
{
  var username : String?
  {
    get { self.string(forKey: "username") }
    set {
      if let u = newValue, u.count > 0
      { self.set(u, forKey: "username") }
      else
      { self.removeObject(forKey: "username") }
    }
  }
  
  var userkey : String?
  {
    get { self.string(forKey: "userkey") }
    set {
      if let uk = newValue, uk.count > 0
      { self.set(uk, forKey: "userkey") }
      else
      { self.removeObject(forKey: "userkey") }
    }
  }
  
  var alias : String?
  {
    get { self.string(forKey: "alias") }
    set {
      if let a = newValue, a.count > 0
      { self.set(a, forKey: "alias") }
      else
      { self.removeObject(forKey: "alias") }
    }
  }
  
  var lastLoss : TimeInterval?
  {
    get { self.object(forKey: "LastLoss") as? TimeInterval }
    set {
      if let t = newValue { self.set(t,       forKey: "LastLoss") }
      else                { self.removeObject(forKey: "LastLoss") }
    }
  }
  
  var lastErrorEmail : TimeInterval
  {
    get { self.object(forKey: "lastErrorEmail") as? TimeInterval ?? 0.0 }
    set { self.set(newValue, forKey: "lastErrorEmail") }
  }
  
  var resetSalt : Int
  {
    get {
      if let cur = self.object(forKey: "ResetSalt") as? Int { return cur }
      let salt = Int.random(in: 1...999999)
      self.set(salt, forKey: "ResetSalt")
      return salt
    }
  }
}
