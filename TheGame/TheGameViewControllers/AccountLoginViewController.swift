//
//  AccountLoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedUsername : String?

class AccountLoginViewController: LoginModalViewController
{
  @IBOutlet weak var username  : LoginTextField!
  @IBOutlet weak var password  : LoginTextField!
  
  @IBOutlet weak var loginButton : UIButton!
  @IBOutlet weak var cancelButton : UIButton!
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    username.text = UserDefaults.standard.username ?? cachedUsername ?? ""
    password.text = ""
    
    update()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    cachedUsername = username.text
  }
  
  // MARK:- IBActions
  
  @IBAction func login(_ sender:UIButton)
  {
    debug("login")
  }
  
  @IBAction func sendLoginInfo(_ sender:UIButton)
  {
    container?.present(ViewControllerID.RetrieveLogin)
  }
  
  func update()
  {
    loginButton.isEnabled =
      (username.text ?? "").count > 0 &&
      (password.text ?? "").count > 0
  }
}

// MARK:- Forgot Login Info

class ForgotLoginViewController: LoginModalViewController
{
}
