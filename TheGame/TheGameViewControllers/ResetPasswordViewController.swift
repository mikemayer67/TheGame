//
//  ResetPasswordViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 5/27/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedUsername : String?

class ResetPasswordViewController: ModalViewController
{
  var loginVC : LoginViewController
  
  private var updateTimer : Timer?
  
  //MARK:- Subviews
  
  var usernameTextField   : LoginTextField!
  var password1TextField  : LoginTextField!
  var password2TextField  : LoginTextField!
  var resetCodeTextField  : LoginTextField!
  
  var usernameInfo         : UIButton!
  var passwordInfo         : UIButton!
  var resetInfo            : UIButton!
  
  var usernameError        : UILabel!
  var passwordError        : UILabel!
  var resetError           : UILabel!
  
  var createButton         : UIButton!
  var cancelButton         : UIButton!

  // MARK:- View State
  
  init(loginVC:LoginViewController)
  {
    self.loginVC = loginVC
    super.init(title: "Reset Password")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
        
    let usernameLabel = addHeader("Username", below: titleRule, gap:Style.contentGap)
    usernameTextField = addLoginEntry(below: usernameLabel)
    usernameTextField.changeCallback = { self.startUpdateTimer() }
    usernameInfo = addInfoButton(to: usernameTextField, target: self)
    usernameError = addErrorLabel(to: usernameInfo)
    
    let passwordLabel = addHeader("New Password", below: usernameTextField)
    password1TextField = addLoginEntry(below: passwordLabel, type:.Password)
    password1TextField.changeCallback = { self.startUpdateTimer() }
    password2TextField = addLoginEntry(below: password1TextField, placeholder: "retype to confirm", type:.Password)
    password2TextField.changeCallback = { self.startUpdateTimer() }
    passwordInfo = addInfoButton(to: password1TextField, target: self)
    passwordError = addErrorLabel(to: passwordInfo)
    
    let resetLabel = addHeader("Reset Code", below:password2TextField)
    resetCodeTextField = addLoginEntry(below: resetLabel, type:.ResetCode)
    resetCodeTextField.changeCallback = { self.startUpdateTimer() }
    resetInfo = addInfoButton(to:resetCodeTextField, target:self)
    resetError = addErrorLabel(to: resetInfo)
    
    cancelButton = addCancelButton()
    createButton = addOkButton(title:"Reset")
    
    cancelButton.attachTop(to: resetCodeTextField, offset: Style.contentGap)
    
    createButton.addTarget(self, action: #selector(reset(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    usernameTextField.text    = cachedUsername ?? Defaults.username ?? ""
    password1TextField.text   = ""
    password2TextField.text   = ""
    
    checkAllAndUpdateState()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    cachedUsername    = self.usernameTextField.text
  }
  
  // MARK:- Input State

  @discardableResult
  func checkAllAndUpdateState() -> Bool
  {
    var allOK = true
    if !checkUsername()    { allOK = false }
    if !checkPassword()    { allOK = false }
    if !checkResetCode()   { allOK = false }
    createButton.isEnabled = allOK
    return allOK
  }
  
  private func checkUsername() -> Bool
  {
    let t = usernameTextField.text ?? ""
    
    var err : String?
    
    if      t.isEmpty                     { err = "(required)" }
    else if t.count < K.MinUsernameLength { err = "too short"  }
    
    let ok = ( err == nil )
    usernameError.text = err
    usernameError.isHidden = ok
    return ok
  }
  
  private func checkPassword() -> Bool
  {
    let t1 = password1TextField.text ?? ""
    let t2 = password2TextField.text ?? ""
    
    var err : String?
    
    if      t1.isEmpty                     { err = "(required)" }
    else if t1.count < K.MinPasswordLength { err = "too short"  }
    else if t2.isEmpty                     { err = "(required)" }
    else if t2.count < t1.count,
      t2 == t1.prefix(t2.count)            { err = "don't match" }
    else if t1 != t2                       { err = "don't match" }
    
    let ok = ( err == nil )
    passwordError.text = err
    passwordError.isHidden = ok
    return ok
  }
  
  private func checkResetCode() -> Bool
  {
    let c = self.resetCode
    
    var err : String?
        
    if c.isEmpty { err = "(required)" }
    else if c.count < K.ResetCodeLength { err = "too short" }
    else if c.count > K.ResetCodeLength { err = "too long" }
    
    let ok = ( err == nil )
    resetError.text = err
    resetError.isHidden = ok
    return ok
  }
  
  private var resetCode : String
  {
    var code = resetCodeTextField.text ?? ""
    code.removeAll(where: { $0.isWhitespace })
    return code
  }
  
  private var validationCode : Int
  {
    guard
      Defaults.hasResetSalt,
      let rc = Int(self.resetCode)
      else { return -1 }
    
    return rc ^ Defaults.resetSalt
  }
  
  // MARK:- Button Actions
  
  @objc func cancel(_ sender:UIButton)
  {
    mmvc?.rollback()
  }
  
  @objc func reset(_ sender:UIButton)
  {
    guard checkAllAndUpdateState(),
      let username = usernameTextField.text,
      let password = password1TextField.text,
      self.validationCode >= 0
    else { return }
    
    TheGame.server.resetPassword(
      username: username,
      password: password,
      resetCode: self.validationCode) { (query) in
        switch query.status {
        case .Success(_):
          self.login(username:username,password:password)
          
        case .QueryFailure(GameQuery.Status.InvalidUsername, _):
          self.infoPopup(title: "Failed to Reset Password",
                         message: "There is no account with username \(username)")
          
        case .QueryFailure(GameQuery.Status.FailedToUpdateUser, _):
          self.infoPopup(title: "Failed to Reset Password",
                         message: ["Invalid password reset code.",
                                   "Verify that you are using the most recently emailed value and that this is the same device from which you requested the password reset code"])
          
        case .FailedToConnect:
          failedToConnectToServer()
          
        default:
          let err =  query.internalError ?? "Unknown Error"
          self.internalError(err , file:#file, function:#function)
        }
    }
  }
  
  func login(username:String, password:String)
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
          failedToConnectToServer()
        case .QueryFailure:
          let err =  "Reset password not being recognized by the server. (\(query.internalError ?? "Unknown Error"))"
          self.internalError(err , file:#file, function:#function)
        default:
          let err =  query.internalError ?? "Unknown Error"
          self.internalError(err , file:#file, function:#function)
        }
      }
    }
  }
}

// MARK:- Text Field Delegate

extension ResetPasswordViewController : UITextFieldDelegate
{
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason)
  {
    startUpdateTimer()
  }
  
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool
  {
    startUpdateTimer()
    return true
  }
  
  func startUpdateTimer()
  {
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false)
    { _ in self.checkAllAndUpdateState() }
  }
}

// MARK:- Info Button Delegate

extension ResetPasswordViewController : InfoButtonDelegate
{
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case usernameInfo:
      infoPopup(title: "Username", message: [
        "Your username must contain at least \(K.MinUsernameLength) characters.",
        "It may contain any combination of letters and numbers"
      ] )
      
    case passwordInfo:
      infoPopup(title: "Password", message: [
        "Your password must contain at least \(K.MinPasswordLength) characters.",
        "It may contain any combination of letters, numbers, or the following punctuation marks: - ! : # $ @ ."
      ])
      
    case resetInfo:
      infoPopup(title: "Password Reset Code", message: [
        "Enter the reset code sent to you by email.",
        "The reset request must have been sent from this device."
      ])
  
    default: break
    }
  }
  
}
