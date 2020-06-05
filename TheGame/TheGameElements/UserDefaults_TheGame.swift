//
//  UserDefaults_TheGame.swift
//  TheGame
//
//  Created by Mike Mayer on 4/28/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

private let Username       = "username"
private let Userkey        = "userkey"
private let Alias          = "alias"
private let LastLoss       = "lastLoss"
private let LastErrorEmail = "lastErrorEmail"
private let ResetSalt      = "resetSalt"

extension UserDefaults
{
  var username : String?
  {
    get { self.string(forKey: Username) }
    set {
      if let u = newValue, u.count > 0
      { self.set(u, forKey: Username) }
      else
      { self.removeObject(forKey: Username) }
    }
  }
  
  var userkey : String?
  {
    get { self.string(forKey: Userkey) }
    set {
      if let uk = newValue, uk.count > 0 { self.set(uk, forKey: Userkey)      }
      else                               { self.removeObject(forKey: Userkey) }
    }
  }
  
  var alias : String?
  {
    get { self.string(forKey: Alias) }
    set {
      if let a = newValue, a.count > 0
      { self.set(a, forKey: Alias) }
      else
      { self.removeObject(forKey: Alias) }
    }
  }
  
  var lastLoss : TimeInterval?
  {
    get { self.object(forKey: LastLoss) as? TimeInterval }
    set {
      if let t = newValue { self.set(t,       forKey: LastLoss) }
      else                { self.removeObject(forKey: LastLoss) }
    }
  }
  
  var lastErrorEmail : TimeInterval
  {
    get { self.object(forKey: LastErrorEmail) as? TimeInterval ?? 0.0 }
    set { self.set(newValue, forKey: LastErrorEmail) }
  }
  
  var curResetSalt : Int? {
    self.object(forKey: ResetSalt) as? Int
  }
  
  var resetSalt : Int
  {
    var salt = self.object(forKey: ResetSalt) as? Int
    if salt == nil {
      salt = Int.random(in: 1...999999)
      self.set(salt, forKey: ResetSalt)
    }
    return salt!
  }
 
  var hasResetSalt : Bool
  {
    get { object(forKey: ResetSalt) != nil }
    set { if !newValue { self.removeObject(forKey: ResetSalt) } }
  }
  
  var dev : Bool
  {
    get { self.object(forKey: "DevTesting") as? Bool ?? false }
    set { self.set(newValue, forKey: "DevTesting") }
  }
  
}
