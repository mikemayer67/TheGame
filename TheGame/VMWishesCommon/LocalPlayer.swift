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
  
  init(_ key:String, username:String?, alias:String? = nil, gameData:HashData? = nil)
  {
    self.username  = username
    self.alias     = alias
    
    Defaults.userkey  = key
    Defaults.username = username
    Defaults.alias    = alias
    
    let name = (
      (alias ?? "").count > 0 ? alias!
        : (username ?? "").count > 0 ? username!
        : UIDevice.current.name )
    
    super.init(key:key, name:name, gameData:gameData)
  }
  
  init(_ key:String, facebook:FacebookInfo, gameData:HashData? = nil)
  {
    self.username  = nil
    self.alias     = nil
    
    track("LocalPlayer FB:\(facebook)")
    
    Defaults.userkey  = key

    super.init(key:key, facebook:facebook, gameData:gameData)
  }
  
  typealias ConnectCallback = (LocalPlayer?)->()
  
  static func connect( completion: @escaping ConnectCallback )
  {
    let userkey  = Defaults.userkey
    
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
                         username: Defaults.username,
                         alias:    Defaults.alias,
                         gameData: data)
      default:
        Defaults.userkey = nil
      }
      
      completion(me)
    }
  }
  
  static func connectFacebook(userkey:String? = nil, completion: @escaping ConnectCallback)
  {
    let request = GraphRequest(graphPath: "me", parameters: ["fields":"id,name,picture,permissions"])
    
    request.start {
      (_, result, error) in
                  
      guard error == nil,
        let fbResult = result as? NSDictionary,
        let fbid     = fbResult["id"]   as? String,
        let name     = fbResult["name"] as? String
        else { completion(nil); return }
                  
      var args : GameQuery.Args = [QueryKey.FBID:fbid]
      if userkey != nil { args[QueryKey.Userkey] = userkey! }
      
      var friends = false
      
      if let permissions = fbResult["permissions"] as? NSDictionary,
        let permissionData = permissions["data"] as? [NSDictionary]
      {
        for perm in permissionData
        {
          if let key = perm["permission"] as? String,
           let status = perm["status"] as? String,
            key == "user_friends", status == "granted"
          {
            friends = true
          }
        }
      }
        
      TheGame.server.query(.User, action: .Connect, args: args).execute() {
        (query) in
                
        var me : LocalPlayer? = nil
        
        if case .Success(let data) = query.status,
          let userkey = userkey ?? data?["userkey"] as? String
        {
          var picture : String?
          if let fbPicture = fbResult["picture"] as? NSDictionary,
            let data = fbPicture["data"] as? NSDictionary,
            let url = data["url"] as? String
          {
            picture = url
          }
          let fb = FacebookInfo(id: fbid, name: name, picture:picture, friendsGranted:friends)
          me = LocalPlayer(userkey, facebook:fb, gameData: data)
        }
        
        completion(me)
      }
    }
  }
  
}
