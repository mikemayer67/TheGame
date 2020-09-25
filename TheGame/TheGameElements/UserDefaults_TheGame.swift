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
private let LastErrorEmail = "lastErrorEmail"
private let ResetSalt      = "resetSalt"
private let APNRequested   = "pushNotificationRequested"

extension UserDefaults
{
  func clear()
  {
    for key in [Username, Userkey, Alias, LastErrorEmail, ResetSalt, APNRequested]
    {
      removeObject(forKey: key)
    }
  }
  
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
  
  var lastErrorEmail : TimeInterval
  {
    get { self.object(forKey: LastErrorEmail) as? TimeInterval ?? 0.0 }
    set { self.set(newValue, forKey: LastErrorEmail) }
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
  
  var pushNotificationRequested : Bool
  {
    get { self.object(forKey: APNRequested) as? Bool ?? false }
    set { self.set(newValue, forKey: APNRequested) }
  }
}
