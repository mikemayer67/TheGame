//
//  LocalPlayer.swift
//  TheGame
//
//  Created by Mike Mayer on 7/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LocalPlayer : Participant
{
  let userkey     : String
  
  private(set) var name       : String
  private(set) var icon       : UIImage? = nil
  private(set) var email      : Email? = nil
    
  init?(_ key:String, data:HashData?)
  {
    guard let data=data, let name=data.name else { return nil }
    
    self.userkey = key
    self.name    = name
    self.email   = data.email
    self.icon    = createIcon(for: name, with: data.picture)
        
    Defaults.userkey  = key
    
    if let t = data.lastLoss, t > 0
    {
      lastLoss = GameTime(networktime: TimeInterval(t))
    }
  }
  
  var lastLoss : GameTime? = nil
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
    
    if AccessToken.current?.appID != Settings.appID { LoginManager().logOut() }
    
    if AccessToken.current != nil
    {
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
    
    request.setGraphErrorRecovery(disabled: true)
    
    request.start { (_, result, error) in
      
      guard error == nil,
        let fbResult = result as? NSDictionary,
        let fbid     = fbResult["id"]   as? String
        else { completion(nil); return }
      
      TheGame.server.login(fbid: fbid) {
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
