//
//  LocalPlayer.swift
//  TheGame
//
//  Created by Mike Mayer on 7/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LocalPlayer : Participant
{
  let userkey     : String
  
  init(_ key:String, data:HashData? = nil)
  {
    self.userkey   = key
    
    Defaults.userkey  = key
    
    var lastLoss : GameTime?
    if let t = data?.lastLoss, t > 0
    {
      lastLoss = GameTime(networktime: TimeInterval(t))
    }
    
    super.init(lastLoss: lastLoss)
  }
  
  override var lastLoss : GameTime?
    {
    didSet {
      TheGame.server.updateLastLoss(userkey: userkey) { (query) in
        switch query.status
        {
        case .FailedToConnect: failedToConnectToServer()
        default: break
        }
      }
    }
  }
  
  typealias ConnectCallback = (LocalPlayer?)->()
  
  static func connect( completion: @escaping ConnectCallback )
  {
    let userkey  = Defaults.userkey
    
    if AccessToken.current != nil {
      connectWithFacebook() { (localPlayer) in
        if let me = localPlayer { completion(me) }
        else if userkey == nil  { completion(nil) }
        else                    { connect(userkey: userkey!, completion: completion) }
      }
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
    TheGame.server.login(userkey: userkey) {
      (query) in
      
      var me : LocalPlayer? = nil
      switch query.status
      {
      case .Success(let data):
        me = LocalPlayer(userkey, data: data)
      default:
        Defaults.userkey = nil
      }
      
      completion(me)
    }
  }
  
  static func connect(qcode:String, scode:String, completion: @escaping (GameQuery,LocalPlayer?)->())
  {
    TheGame.server.login(qcode: qcode, scode: scode) {
      (query) in
      
      var me : LocalPlayer? = nil
      switch query.status
      {
      case .Success(let data):
        if let userkey = data?[QueryKey.Userkey] as? String {
          me = LocalPlayer(userkey, data: data)
        }
      default:
        Defaults.userkey = nil
      }
      
      completion(query,me)
    }
  }
  
  static func connectWithFacebook(completion: @escaping ConnectCallback)
  {
    let request = GraphRequest(graphPath: "me", parameters: ["fields":"id,name"])
    
    request.start { (_, result, error) in
      
      guard error == nil,
        let fbResult = result as? NSDictionary,
        let fbid     = fbResult["id"]   as? String,
        let name     = fbResult["name"] as? String
        else { completion(nil); return }
      
      TheGame.server.login(fbid: fbid, name:name) {
        (query) in
        
        var me : LocalPlayer? = nil
        
        if case .Success(let data) = query.status,
          let userkey = data?["userkey"] as? String
        {
          me = LocalPlayer(userkey,data:data)
        }
        
        completion(me)
      }
    }
  }
  
}
