//
//  LoginModalViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 10/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
 Subclass of *ModalViewController* which serves as parent class of all the modal view
 controllers which support user login
 */
class LoginModalViewController : ModalViewController
{
  var loginVC : LoginViewController
  var updateTimer : Timer?
  
  init(title:String, loginVC:LoginViewController)
  {
    self.loginVC = loginVC
    super.init(title: title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) not supported")
  }
  
  func startUpdateTimer(interval:TimeInterval = 0.3, block:@escaping (Timer)->())
  {
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false)
    {
      _ in self.checkAllAndUpdateState()
    }
  }
  
  @discardableResult
  func checkAllAndUpdateState() -> Bool
  {
    return true
  }
}
