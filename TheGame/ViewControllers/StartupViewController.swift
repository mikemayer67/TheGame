//
//  StartupViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/27/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class StartupViewController: UIViewController
{
  @IBOutlet weak var failedLabel : UILabel!
  @IBOutlet weak var reconnectLabel : UILabel!
  @IBOutlet weak var spinner : UIActivityIndicatorView!
  
  var connectionAttempt = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    connectionAttempt = 0
    testConnection()
  }
  
  func testConnection()
  {
    failedLabel.isHidden = true
    reconnectLabel.isHidden = true
    spinner.isHidden = false
    
    connectionAttempt = connectionAttempt + 1
        
    GameServer.shared.testConnection { (response) in
      if case .ConnectionExists = response
      {
        GameServer.shared.testLogin { _ in
          RootViewController.shared.update()
        }
      }
      else
      {
        self.startRetryConnection()
      }
    }
  }
  
  func startRetryConnection()
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
    self.spinner.isHidden = true
    
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
      self.updateRetryConnection(wait-1)
    }
  }
  
  func updateRetryConnection(_ wait:Int)
  {
    if wait == 0
    {
      self.testConnection()
    }
    else
    {
      let unit = (wait == 1 ? "second" : "seconds")
      self.reconnectLabel.text = "Trying again in \(wait) \(unit)"
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        self.updateRetryConnection(wait - 1)
      }
    }
  }
  
}
