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
    password = addLoginEntry(below: passwordLabel, type:.Password)
    password.changeCallback = { self.startUpdateTimer() }
    passwordInfo = addInfoButton(to: password, target: self)
    
    let oops = UIButton(type: .system)
    managedView.addSubview(oops)
    oops.translatesAutoresizingMaskIntoConstraints = false
    oops.setTitle("Oops... I forgot my login info", for: .normal)
    oops.titleLabel?.font = UIFont.italicSystemFont(ofSize: 14)
    oops.alignCenterX(to: managedView)
    oops.attachTop(to: password,offset: Style.fieldGap)
    
    var resetpw : UIButton?
    if Defaults.hasResetSalt
    {
      let button = UIButton(type: .system)
      managedView.addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle("Reset Password", for: .normal)
      button.titleLabel?.font = UIFont.italicSystemFont(ofSize: 14)
      button.alignCenterX(to: managedView)
      button.attachTop(to: oops,offset: Style.actionGap)
      button.addTarget(self, action: #selector(sendPasswordReset(_:)), for: .touchUpInside)
      resetpw = button
    }
    
    cancelButton = addCancelButton()
    loginButton  = addOkButton(title: "Connect")
    
    cancelButton.attachTop(to: resetpw ?? oops,offset: Style.contentGap)
    
    oops.addTarget(self, action: #selector(sendLoginInfo(_:)), for: .touchUpInside)
    loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    username.text = Defaults.username ?? cachedUsername ?? ""
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
    let ok = (username.text?.count ?? 0) >= K.MinUsernameLength && (password.text?.count ?? 0) >= K.MinPasswordLength
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
    if let username = self.username.text, let password = self.password.text
    {
      LocalPlayer.connect(username: username, password: password) {
        (query, me) in
        if me != nil
        {
          TheGame.shared.me  = me
          self.loginVC.completed(self)
        }
        else
        {
          switch query.status
          {
          case .FailedToConnect:
            self.loginVC.cancel(self,updateRoot: true)
          case .QueryFailure:
            self.infoPopup(title: "Failed to Login", message: "Incorrect username or password")
            self.password.text = ""
          default:
            let err =  query.internalError ?? "Unknown Error"
            self.internalError(err , file:#file, function:#function)
          }
        }
      }
    }
  }
  
  @objc func sendLoginInfo(_ sender:UIButton)
  {
    mmvc?.present(.RetrieveLogin)
  }
  
  @objc func sendPasswordReset(_ sender:UIButton)
  {
    mmvc?.present(.ResetPassword)
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
        "Must be at least \(K.MinUsernameLength) characters long.",
        "May contain any combination of letters and numbers"
      ] )
      
    case passwordInfo:
      self.infoPopup(title: "Password Hints", message: [
        "Must be at least \(K.MinPasswordLength) characters long",
        "May only contain letters, numbers, or any of the following: - ! : # $ @ ."
      ])
      
    default: break
    }
  }
}
