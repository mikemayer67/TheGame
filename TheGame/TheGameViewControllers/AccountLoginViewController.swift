//
//  AccountLoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedUsername : String?

class AccountLoginViewController: ModalViewController
{
  var loginVC : LoginViewController
  
  private var updateTimer : Timer?

  // MARK:- Subviews
  
  var username     : LoginTextField!
  var usernameInfo : UIButton!
  var password     : LoginTextField!
  var passwordInfo : UIButton!
  
  var loginButton : UIButton!
  var cancelButton : UIButton!
  
  // MARK:- View State
  
  init(loginVC:LoginViewController)
  {
    self.loginVC = loginVC
    super.init(title: "Login")
  }
  
  required init?(coder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
            
    let usernameLabel = addHeader("Username", below: titleRule, gap: Style.contentGap)
    username = addLoginEntry(below: usernameLabel)
    username.changeCallback = { self.startUpdateTimer() }
    usernameInfo = addInfoButton(to: username, target: self)
    
    let passwordLabel = addHeader("Password", below: username)
    password = addLoginEntry(below: passwordLabel, password: true)
    password.changeCallback = { self.startUpdateTimer() }
    passwordInfo = addInfoButton(to: password, target: self)
    
    let oops = UIButton(type: .system)
    managedView.addSubview(oops)
    oops.translatesAutoresizingMaskIntoConstraints = false
    oops.setTitle("Oops... I forgot my login info", for: .normal)
    oops.titleLabel?.font = UIFont.italicSystemFont(ofSize: 14)
    oops.alignCenterX(to: managedView)
    oops.attachTop(to: password,offset: Style.fieldGap)
    
    cancelButton = addCancelButton()
    loginButton  = addOkButton(title: "Connect")
    
    cancelButton.attachTop(to: oops,offset: Style.contentGap)
    
    oops.addTarget(self, action: #selector(sendLoginInfo(_:)), for: .touchUpInside)
    loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    username.text = UserDefaults.standard.username ?? cachedUsername ?? ""
    password.text = ""

    checkAllAndUpdateState()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)
    cachedUsername = username.text
  }
  
  // MARK:- Input State
  
  @discardableResult
  func checkAllAndUpdateState() -> Bool
  {
    let ok = (username.text?.count ?? 0) >= 6 && (password.text?.count ?? 0) >= 8
    loginButton.isEnabled = ok
    return ok
  }
  
  func startUpdateTimer()
  {
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false)
    { _ in self.checkAllAndUpdateState() }
  }
  
  // MARK:- Button Actions
  
  @objc func cancel(_ sender:UIButton)
  {
    loginVC.cancel(self)
  }
  
  @objc func login(_ sender:UIButton)
  {
    debug("login")
  }
  
  @objc func sendLoginInfo(_ sender:UIButton)
  {
    container?.present(.RetrieveLogin)
  }
}

// MARK:- Info Button Delegate

extension AccountLoginViewController : InfoButtonDelegate
{
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case usernameInfo:
      infoPopup(title: "Username Hints", message: [
        "Must be at least 6 characters long.",
        "May contain any combination of letters and numbers"
      ] )
      
    case passwordInfo:
      self.infoPopup(title: "Password Hints", message: [
        "Must be at least 8 characters long",
        "May only contain letters, numbers, or any of the following: - ! : # $ @ ."
      ])
      
    default: break
    }
  }
}
