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
      UserDefaults.standard.userkey  = key
      UserDefaults.standard.username = username
      UserDefaults.standard.alias    = alias
      
      var name = UIDevice.current.name
      if let username = username, username.count > 0 { name = username }
      if let alias = alias, alias.count > 0          { name = alias }
      super.init(key:key, name:name, gameData:gameData)
    }
  }
  
  typealias ConnectCallback = (LocalPlayer?)->()
  
  static func connect( completion: @escaping ConnectCallback )
  {
    let userkey  = UserDefaults.standard.userkey
    
    if AccessToken.current != nil {
      connectFacebook(userkey:userkey, completion:completion)
    }
    else if let userkey = userkey {
      connect(userkey:userkey, completion:completion)
    }
    else {
      completion(nil)
    }
  }
  
  static func connect(userkey:String, completion: @escaping ConnectCallback)
  {
    let args : GameQuery.Args = [QueryKey.Userkey:userkey]

    TheGame.server.query(.User, action: .Validate, args: args).execute() {
      (query) in
            
      var me : LocalPlayer? = nil
      switch query.status
      {
      case .Success(let data):
        me = LocalPlayer(userkey,
                         username: UserDefaults.standard.username,
                         alias:    UserDefaults.standard.alias,
                         gameData: data)
      default:
        UserDefaults.standard.userkey = nil
      }
      
      completion(me)
    }
  }
  
  static func connectFacebook(userkey:String?, completion: @escaping ConnectCallback)
  {
    let request = GraphRequest(graphPath: "me", parameters: ["fields":"id,name,picture"])
    
    request.start {
      (_, result, error) in
      debug("@@@FB callback")
                  
      guard error == nil,
        let fbResult = result as? NSDictionary,
        let fbid     = fbResult["id"]   as? String,
        let name     = fbResult["name"] as? String
        else { completion(nil); return }
      
      var args : GameQuery.Args = [QueryKey.FBID:fbid]
      if userkey != nil { args[QueryKey.Userkey] = userkey! }
        
      TheGame.server.query(.User, action: .Connect, args: args).execute() {
        (query) in
        
        var me : LocalPlayer? = nil
        
        if case .Success(let data) = query.status,
          let userkey = userkey ?? fbResult["userkey"] as? String
        {
          let fb = FacebookInfo(id: fbid, name: name, picture: nil)
          me = LocalPlayer(userkey, facebook:fb, gameData: data)
        }
        
        completion(me)
      }
    }
  }
  
}
