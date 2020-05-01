//
//  LocalPlayer.swift
//  TheGame
//
//  Created by Mike Mayer on 4/26/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LocalPlayer : GamePlayer
{
  let username    : String?
  let alias       : String?
  
  init(_ key:String, username:String? = nil, alias:String? = nil, facebook:FacebookInfo? = nil, gameData:HashData? = nil)
  {
    self.username  = username
    self.alias     = alias

    if let fb = facebook
    {
      super.init(key:key, facebook:fb, gameData:gameData)
    }
    else
    {
      var name = UIDevice.current.name
      if let username = username, username.count > 0 { name = username }
      if let alias = alias, alias.count > 0          { name = alias }
      super.init(key:key, name:name, gameData:gameData)
    }
  }
  
  typealias ConnectCallback = (LocalPlayer?)->()
  
  static func connect( completion: @escaping ConnectCallback )
  {
    let userkey  = UserDefaults.standard.string(forKey: "userkey")

    if AccessToken.current != nil { connectFacebook(userkey:userkey, completion:completion)  }
    else if let userkey = userkey { connect(userkey:userkey, completion:completion)          }
    else                          { completion(nil) }
  }
  
  static func connect(userkey:String, completion: @escaping ConnectCallback)
  {
    let args : GameQueryArgs = [.Userkey:userkey]
    TheGame.server.query(.User, action: .Validate, gameArgs: args)
    {
      (response) in
      if response.success
      {
        let me = LocalPlayer(userkey,
                             username: UserDefaults.standard.string(forKey: "username"),
                             alias: UserDefaults.standard.string(forKey: "alias"),
                             gameData: response.data)
        completion(me)
      }
      else
      {
        UserDefaults.standard.removeObject(forKey: "userkey")
        completion(nil)
      }
    }
  }
  
  static func connectFacebook(userkey:String?, completion: @escaping ConnectCallback)
  {
    let request = GraphRequest(graphPath: "me", parameters: ["fields":"id,name,picture"])
    
    request.start {
      (_, result, error) in
      debug("FB callback")
            
      if error == nil,
        let fbResult = result as? NSDictionary,
        let fbid     = fbResult["id"]   as? String,
        let name     = fbResult["name"] as? String
      {
        var args : GameQueryArgs = [.FBID:fbid]
        if userkey != nil { args[.Userkey] = userkey! }
        
        TheGame.server.query(.User, action: .Connect, gameArgs: args)
        {
          (response) in
          
          if let userkey = userkey ?? ( fbResult["userkey"] as? String )
          {
            let fb = FacebookInfo(id: fbid, name: name, picture: nil)
            let me = LocalPlayer(userkey, facebook:fb, gameData: response.data)
            completion(me)
          }
          else
          {
            completion(nil)
          }
        }
      }
      else
      {
        completion(nil)
      }
    }
  }
}
