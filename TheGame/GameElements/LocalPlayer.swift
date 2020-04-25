//
//  LocalPlayer.swift
//  TheGame
//
//  Created by Mike Mayer on 4/3/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation
import FacebookLogin

typealias LocalPlayerCreateCallback = (LocalPlayer?)->()

class LocalPlayer : Player
{
  // Username/Password account
  let username    : String?
  let alias       : String?
  
  // Facebook account
  // Helpful links:
  //   https://www.youtube.com/watch?v=tSIYcQmUav4
  
  // Designated Initializer for user account with or without facebook account
  init(_ key:String, username:String?, alias:String?, fb:FBUserInfo? = nil, lastLoss:GameTime?)
  {
    self.username             = username
    self.alias                = alias
    
    var name = UIDevice.current.name
    
    if let fb = fb                  { name = fb.name }
    else if let alias = alias       { name = alias }
    else if let username = username { name = username }
    
    super.init(key:key, name:name, fb:fb, lastLoss: lastLoss)
  }
    
  // Designated Initializier for facebook account only
//  init(_ userkey:String, fb:FBUserInfo, lastLoss:GameTime? = nil)
//  {
//    self.username             = nil
//    self.alias                = nil
//    self.emailStatus          = .NoEmail
//    
//    super.init(key:key, name:fb.name, fb:fb, lastLoss:lastLoss)
//  }
  
//  // Convenience Iniitializer using UserDefaults
//  //   This initializer will block waiting on Game Server
//  convenience init?()
//  {
//    guard let key = UserDefaults.standard.string(forKey: "userkey") else { return nil }
//
//    let username = UserDefaults.standard.string(forKey: "username")
//
//    let fbid : String? = nil
//    debug("Add Facebook ID validation")
//
//    var queryArgs = [ "action":"validate", "userkey":key ]
//    if username != nil { queryArgs["username"] = username }
//    if fbid     != nil { queryArgs["fbid"]     = fbid     }
//
//    let response = TheGame.server.query("user", args: queryArgs)
//    guard response.rc == .Success else { return nil }
//    guard let data = response.data else { return nil }
//
//    let alias = data["alias"] as? String
//
//    var emailStatus : EmailStatus = .NoEmail
//
//    if let email = data["email"] as? Int {
//      emailStatus = ( email == 1 ? .HasValidatedEmail : .HasUnvalidatedEmail )
//    } else {
//      emailStatus = .NoEmail
//    }
//
//    let userAccountValidated = ( data["username"] as? Int == 1 )
//    let fbAccountValidated   = ( data["fbid"]     as? Int == 1 )
//
//    guard userAccountValidated || fbAccountValidated else { return nil }
//
//    var lastLoss : GameTime?
//    if let ll = data["last_loss"] as? Int, ll > 0
//    {
//      lastLoss = GameTime(networktime: TimeInterval(ll))
//    }
//
//    var fb : FBUserInfo?
//    if fbAccountValidated
//    {
//      debug("Add Facebook info retrieval")
//    }
//
//    if userAccountValidated {
//      guard let username = username else { return nil }
//      self.init(key, username:username, alias:alias, emailStatus:emailStatus, fb:fb, lastLoss:lastLoss)
//    } else {
//      self.init(key, fb:fb!, lastLoss:lastLoss)
//    }
//  }
  
//  static func create(username:String, password:String, alias:String, email:String,
//                     completion: @escaping (QueryResponse)->())
//  {
//    var queryItems : [String:String] = [
//      "action"   : "create",
//      "username" : username ,
//      "password" : password
//    ]
//    if !alias.isEmpty { queryItems["alias"] = alias }
//    if !email.isEmpty { queryItems["email"] = email }
//
//    TheGame.server.query("user", args: queryItems)
//    {
//      (response) in
//      switch response.rc
//      {
//      case .Success: // successfully created a new user (but only if userkey was returned)
//        if let data = response.data,
//          let userkey = data["userkey"] as? String
//        {
//          let emailStatus = ( email.isEmpty ? EmailStatus.NoEmail : EmailStatus.HasUnvalidatedEmail )
//          let localPlayer = LocalPlayer(userkey, username: username, alias: alias, emailStatus: emailStatus, facebook: false, lastLoss: nil)
//          completion(.UserCreated(localPlayer))
//        } else {
//          completion(.ServerError)
//        }
//
//      case .UserExists: // user exists (determine if they specified an email and whether or not it's validated)
//        var emailStatus = EmailStatus.NoEmail
//        if let data = response.data, let email = data["email"] as? Int
//        {
//          emailStatus = ( email == 1 ? .HasValidatedEmail : .HasUnvalidatedEmail )
//        }
//        completion(.UserAlreadyExists(emailStatus))
//
//      case .FailedToConnect:
//        completion(.FailedToConnect)
//
//      default:
//        // We got a response, but it's not consistent with the API
//        completion(.ServerError)
//      }
//    }
//  }
}
