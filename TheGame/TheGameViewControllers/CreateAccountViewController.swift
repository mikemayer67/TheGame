//
//  CreateAccountViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedUsername    : String?
fileprivate var cachedDisplayName : String?
fileprivate var cachedEmail       : String?

class CreateAccountViewController : ModalViewController
{
  var loginVC : LoginViewController
  
  private var updateTimer : Timer?
  
  //MARK:- Subviews
  
  var usernameTextField    : LoginTextField!
  var password1TextField   : LoginTextField!
  var password2TextField   : LoginTextField!
  var displayNameTextField : UITextField!
  var emailTextField       : UITextField!
  
  var usernameInfo         : UIButton!
  var passwordInfo         : UIButton!
  var displayNameInfo      : UIButton!
  var emailInfo            : UIButton!
  
  var usernameError        : UILabel!
  var passwordError        : UILabel!
  var displayNameError     : UILabel!
  var emailError           : UILabel!
  
  var createButton         : UIButton!
  var cancelButton         : UIButton!
  
  // MARK:- View State
    
  init(loginVC:LoginViewController)
  {
    self.loginVC = loginVC
    super.init(title: "Create New Account")
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
    
    let passwordLabel = addHeader("Password", below: usernameTextField)
    password1TextField = addLoginEntry(below: passwordLabel, password: true)
    password1TextField.changeCallback = { self.startUpdateTimer() }
    password2TextField = addLoginEntry(below: password1TextField, placeholder: "retype to confirm", password: true)
    password2TextField.changeCallback = { self.startUpdateTimer() }
    passwordInfo = addInfoButton(to: password1TextField, target: self)
    passwordError = addErrorLabel(to: passwordInfo)
    
    let gap = addGap(below:password2TextField)
    
    let displayNameLabel = addHeader("Display Name", below:gap)
    displayNameTextField = addTextEntry(below: displayNameLabel)
    displayNameTextField.delegate = self
    displayNameInfo = addInfoButton(to:displayNameTextField, target:self)
    displayNameError = addErrorLabel(to: displayNameInfo)
    
    let emailLabel = addHeader("Email", below:displayNameTextField)
    emailTextField = addTextEntry(below: emailLabel, email: true)
    emailTextField.delegate = self
    emailInfo = addInfoButton(to: emailTextField, target: self)
    emailError = addErrorLabel(to: emailInfo)
    
    cancelButton = addCancelButton()
    createButton = addOkButton(title:"Connect")
    
    cancelButton.attachTop(to: emailTextField, offset: Style.contentGap)
    
    createButton.addTarget(self, action: #selector(create(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    usernameTextField.text    = cachedUsername ?? ""
    password1TextField.text   = ""
    password2TextField.text   = ""
    displayNameTextField.text = cachedDisplayName ?? ""
    emailTextField.text       = cachedEmail ?? ""
    
    checkAllAndUpdateState()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    cachedUsername    = self.usernameTextField.text
    cachedDisplayName = self.displayNameTextField.text
    cachedEmail       = self.emailTextField.text
  }
  
  // MARK:- Input State

  @discardableResult
  func checkAllAndUpdateState() -> Bool
  {
    var allOK = true
    if !checkUsername()    { allOK = false }
    if !checkPassword()    { allOK = false }
    if !checkDisplayName() { allOK = false }
    if !checkEmail()       { allOK = false }
    createButton.isEnabled = allOK
    return allOK
  }
  
  private func checkUsername() -> Bool
  {
    let t = usernameTextField.text ?? ""
    
    var err : String?
    
    if      t.isEmpty   { err = "(required)" }
    else if t.count < 6 { err = "too short"  }
    
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
    
    if      t1.isEmpty            { err = "(required)" }
    else if t1.count < 8          { err = "too short"  }
    else if t2.isEmpty            { err = "confirmation missing" }
    else if t2.count < t1.count,
      t2 == t1.prefix(t2.count)   { err = "confirmation incomplete" }
    else if t1 != t2              { err = "passwords don't match" }
    
    let ok = ( err == nil )
    passwordError.text = err
    passwordError.isHidden = ok
    return ok
  }
  
  private func checkDisplayName() -> Bool
  {
    let t = (displayNameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    var err : String?
    
    if t.count > 0, t.count<6 { err = "too short" }
    
    let ok = ( err == nil )
    displayNameError.text = err
    displayNameError.isHidden = ok
    return ok
  }
  
  private func checkEmail() -> Bool
  {
    let t = (emailTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    // From http://emailregex.com
    let emailRegex = #"""
      (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])
      """#
    
    var err : String?
    
    if !t.isEmpty,  t.range(of:emailRegex, options: .regularExpression) == nil
    {
      err = "invalid address"
    }
    
    let ok = ( err == nil )
    emailError.text = err
    emailError.isHidden = ok
    return ok
  }
  
  // MARK:- Button Actions
  
  @objc func cancel(_ sender:UIButton)
  {
    loginVC.cancel(self)
  }
  
  @objc func create(_ sender:UIButton)
  {
    guard checkAllAndUpdateState(),
      usernameTextField.text != nil,
      password1TextField.text != nil
    else { return }
    
    if let email = emailTextField.text, !email.isEmpty
    {
      checkForExisting(email:email)
    }
    else
    {
      confirmNoEmail()
    }
  }
  
  private func checkForExisting(email:String)
  {
    TheGame.server.checkFor(email: email) { (exists,query) in
      
      if let exists = exists
      {
        if exists { self.confirmDuplicateEmail(email) }
        else      { self.createAccount() }
      }
      else
      {
        switch query.status
        {
        case .FailedToConnect:
          self.loginVC.cancel(self, updateRoot: true)
          
        default: // includes .none (coding error) or Success (handled above)
          let err =  query.internalError ?? "Unknown Error"
          self.internalError(err , file:#file, function:#function)
        }
      }
    }
  }

  private func confirmNoEmail()
  {
    let message = [
      "Creating an account without an email address is acceptable.",
      "But if you choose to proceed without one, it might not be possible to recover your username or password if lost"
    ]
    
    confirmationPopup( title:"Proceed without Email", message:message, ok:"Proceed")
    { (proceed) in
      if proceed { self.createAccount() }
    }
  }
  
  private func confirmDuplicateEmail(_ email:String)
  {
    let alert = UIAlertController(
      title: "What do you want to do?",
      message: "The email address \(email) is already associated with an account",
      preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "login to that account", style: .default, handler: { _ in
      self.mmvc?.present(.AccountLogin)
    }))
    alert.addAction(UIAlertAction(title: "request login info", style: .default, handler: { _ in
      self.mmvc?.present(.RetrieveLogin)
    }))
    alert.addAction(UIAlertAction(title: "create new account anyway", style: .default, handler: { _ in
      self.createAccount()
    }))
    alert.addAction(UIAlertAction(title: "use a different email", style: .cancel))
    
    self.present(alert,animated: true)
  }
  
  private func createAccount()
  {
    guard checkAllAndUpdateState() else { return }
    guard let username = usernameTextField.text  else { return }
    guard let password = password1TextField.text else { return }
    
    let alias = displayNameTextField.text
    let email = emailTextField.text
    
    TheGame.server.requestNewAccount(
      username: username,
      password: password,
      alias: alias,
      email: email ) {  (query) in
        switch query.status {
        case .Success(let data):
          self.createAccount(username:username,alias:alias,email:email,data:data!)
        case .QueryFailure(GameQuery.Status.UserExists, _):
          self.handleExistingUser(username:username)
        case .FailedToConnect:
          self.loginVC.cancel(self, updateRoot: true)
        default: // includes nil status
          let err =  query.internalError ?? "Unknown Error"
          self.internalError(err , file:#file, function:#function)
        }
    }
  }
  
  private func createAccount(username:String, alias:String?, email:String?, data:HashData)
  {
    guard let userkey = data.userkey
      else { fatalError("query should have failed without userkey in the data") }
    
    var message = ["Username: \(username)"]
    if let alias = alias, alias.count > 0 {
      message.append("Alias: \(alias)")
    }
    if let email = email, email.count > 0 {
      message.append("Check your email for instructions on validating your email address")
    }
    
    TheGame.shared.me =
      LocalPlayer(userkey, username: username, alias: alias, gameData: data)
    
    self.infoPopup(title: "User Created", message: message) {
      self.loginVC.completed(self)
    }
  }
  
  private func handleExistingUser(username:String)
  {
    let message = "Would you like to log in as \(username)?"
    self.confirmationPopup(
      title: "User Exists",
      message:message,
      ok: "Yes", cancel: "No",
      animated: true )
    { (swithToLogin) in
      if swithToLogin  {
        UserDefaults.standard.username = self.usernameTextField.text!
        self.mmvc?.present(.AccountLogin)
      } else {
        self.usernameTextField.selectAll(self)
      }
    }
  }
  
}

// MARK:- Text Field Delegate

extension CreateAccountViewController : UITextFieldDelegate
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

extension CreateAccountViewController : InfoButtonDelegate
{
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case usernameInfo:
      infoPopup(title: "Username", message: [
        "Your username must contain at least 6 characters.",
        "It may contain any combination of letters and numbers"
      ] )
      
    case passwordInfo:
      infoPopup(title: "Password", message: [
        "Your password must contain at least 8 characters.",
        "It may contain any combination of letters, numbers, or the following punctuation marks: - ! : # $ @ ."
      ])
      
    case displayNameInfo:
      infoPopup(title: "Display Name", message: [
        "Specifying a display name is optional.",
        "If provided, this is the name that will be displayed to other players in the game.",
        "If you choose to specify a display name, it must be at least 6 characters long.",
        "If you choose to not provide a display name, your username will be displayed to other players."
      ])
      
    case emailInfo:
      infoPopup(title:"Email", message: [
        "Specifying your email is optional.",
        "If provided, your email will only  be used to recover a lost username or password. It will not be used for any other purpose.",
        "If you choose to not provide an email address, it won't be possible to recover your username or password if lost."
      ])
    default: break
    }
  }
}
