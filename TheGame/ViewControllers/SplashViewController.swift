//
//  SplashViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/27/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController
{
  @IBOutlet weak var failedLabel    : UILabel!
  @IBOutlet weak var reconnectLabel : UILabel!
  
  var connectionAttempt = 0
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    connectionAttempt = 0
    testConnection()
  }
  
  func testConnection()
  {
    failedLabel.isHidden    = true
    reconnectLabel.isHidden = true

    connectionAttempt = connectionAttempt + 1

    TheGame.server.testConnection { (connected) in
      if connected
      {
        AppDelegate.rootViewController.update()
      }
      else
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
        self.reconnectLabel.text = "Trying again in \(wait) seconds"

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
          self.retryConnection(wait-1)
        }
      }
    }
  }

  func retryConnection(_ wait:Int)
  {
    if wait == 0
    {
      self.testConnection()
    }
    else
    {
      self.reconnectLabel.text = "Trying again in \(wait) second\(wait > 1 ? "s" : "")"
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        self.retryConnection(wait - 1)
      }
    }
  }
  
}
