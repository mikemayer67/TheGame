//
//  SplashViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/27/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

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
      if connected {
        LocalPlayer.connect { (localPlayer) in
          TheGame.shared.me = localPlayer
          self.rootViewController.update()
        }
      } else {
        self.startRetryTimer()
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
    if wait == 0  {  self.attemptToConnect()  }
    else
    {
      self.reconnectLabel.text = "Trying again in \(wait) second\(wait > 1 ? "s" : "")"
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        self.retryConnection(in:wait - 1)
      }
    }
  }
  
}
