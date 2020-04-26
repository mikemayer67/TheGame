//
//  SplashViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/27/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SplashViewController: ChildViewController
{
  @IBOutlet weak var failedLabel    : UILabel!
  @IBOutlet weak var reconnectLabel : UILabel!
    
  var connectionAttempt = 0
  
  override func viewDidAppear(_ animated: Bool)
  {
    connectionAttempt = 0
    attemptToConnect()
  }
  
  private func attemptToConnect()
  {
    failedLabel.isHidden    = true
    reconnectLabel.isHidden = true

    connectionAttempt = connectionAttempt + 1

    TheGame.server.testConnection { (connected) in
      if connected
      {
        let userkey  = UserDefaults.standard.string(forKey: "userkey")
        
        if AccessToken.current != nil { self.connectFacebook(userkey:userkey)   }
        else if let userkey = userkey { self.validate(userkey:userkey)          }
        else                          { self.updateRootView()                   }
      }
      else
      {
        self.startRetryTimer()
      }
    }
  }
  
  private func validate(userkey:String)
  {
    let args : GameQueryArgs = [.Userkey:userkey]
    TheGame.server.query(.User, action: .Validate, gameArgs: args)
    {
      (response) in
      if response.success
      {
        var last_loss : GameTime?
        if let t = response.lastLoss
        {
          last_loss = GameTime(networktime: TimeInterval(t))
        }
        let username = UserDefaults.standard.string(forKey: "username")
        let alias    = UserDefaults.standard.string(forKey: "alias")
        
        TheGame.shared.me =
          LocalPlayer(userkey, username: username, alias: alias, lastLoss: last_loss)
      }
      else
      {
        UserDefaults.standard.removeObject(forKey: "userkey")
      }
      self.updateRootView()
    }
  }
  
  private func connectFacebook(userkey:String?)
  {
    let request = GraphRequest(graphPath: "me", parameters: ["fields":"name"])
    request.start { (_, result, error) in
      debug("FB callback")
      if error == nil,
        let result = result as? NSDictionary,
        let fbid = result["id"] as? String
      {
        var args : GameQueryArgs = [.FBID:fbid]
        if let uk = userkey { args[.Userkey] = uk }
        TheGame.server.query(.User, action: .Connect, gameArgs: args)
        {
          (response) in
          debug("Create ME from F")
          self.updateRootView()
        }
      }
      else
      {
        self.updateRootView()
      }
    }
  }
  
  private func startRetryTimer()
  {
    var wait : Int = 0

    switch self.connectionAttempt
    {
    case ..<5:  wait = 5
    case ..<10: wait = 10
    case ..<15: wait = 20
    case ..<20: wait = 30
    case ..<30: wait = 45
    default:    wait = 60
    }

    self.failedLabel.isHidden = false
    self.reconnectLabel.isHidden = false
    
    retryConnection(in: wait)
  }

  private func retryConnection(in wait:Int)
  {
    if wait == 0
    {
      self.attemptToConnect()
    }
    else
    {
      self.reconnectLabel.text = "Trying again in \(wait) second\(wait > 1 ? "s" : "")"
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        self.retryConnection(in:wait - 1)
      }
    }
  }
  
}
