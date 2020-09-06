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

/**
 Subclass of *ModalViewController* which displays the modal view for creating
 a new username/password account
 */
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
    password1TextField = addLoginEntry(below: passwordLabel, type:.Password)
    password1TextField.changeCallback = { self.startUpdateTimer() }
    password2TextField = addLoginEntry(below: password1TextField, placeholder: "retype to confirm", type:.Password)
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

  /**
   Runs checks on each of the input fields.
   
   If any check fails, the create (OK) button is disabled.
   
   If all checks pass, the create button is enabled.
   */
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
  
  /**
   Verifies that the entered username contains is not empty and has the required
   length.
   
   Username checks and corresponding error text:
   - not empty (*required*)
   - required minimum length (*too short*)
   
   - Returns: flag indicating if username check passed
   */
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
  
  /**
   Verifies that the entered password meets all requirements and that it matches
   the password confirmation field.
   
   Password checks and corresponding error text:
   - not empty (*required*)
   - required minimum length (*too short*)
   
   Confirmation checks and corresponding error text:
   - not empty (*required*)
   - same length as password (*incomplete* if shorter, but matches so far, *don't match* otherwise)
   - matches password exactly (*don't match*)
   
   - Returns: flag indicating if password check passed
   */
  private func checkPassword() -> Bool
  {
    let t1 = password1TextField.text ?? ""
    let t2 = password2TextField.text ?? ""
    
    var err : String?
    
    if      t1.isEmpty                     { err = "(required)" }
    else if t1.count < K.MinPasswordLength { err = "too short"  }
    else if t2.isEmpty                     { err = "confirmation missing" }
    else if t2.count < t1.count,
      t2 == t1.prefix(t2.count)            { err = "confirmation incomplete" }
    else if t1 != t2                       { err = "passwords don't match" }
    
    let ok = ( err == nil )
    passwordError.text = err
    passwordError.isHidden = ok
    return ok
  }
  
  /**
   Verifies that the entered display name (alias) meets all requirements.
   
   This field is allowed to be empty, but if not...
   
   Display name checks and corresponding error text:
   - required minimum length (*too short*)
   
   - Returns: flag indicating if display name check passed
   */
  private func checkDisplayName() -> Bool
  {
    let t = (displayNameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    var err : String?
    
    if t.count > 0, t.count < K.MinUsernameLength { err = "too short" }
    
    let ok = ( err == nil )
    displayNameError.text = err
    displayNameError.isHidden = ok
    return ok
  }
  
  /**
   Verifies that the entered email address meets all requirements.
   
   This field is allowed to be empty, but if not...
   
   Display name checks and corresponding error text:
   - matches the email regex defined at http://emailregex.com
   
   - Returns: flag indicating if email check passed
   */
  private func checkEmail() -> Bool
  {
    let t = (emailTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    var err : String?
    
    if !t.isEmpty,  t.range(of:K.emailRegex, options: .regularExpression) == nil
    {
      err = "invalid address"
    }
    
    let ok = ( err == nil )
    emailError.text = err
    emailError.isHidden = ok
    return ok
  }
  
  // MARK:- Button Actions
  
  /// Simply dismisses the current modal view
  @objc func cancel(_ sender:UIButton)
  {
    loginVC.cancel()
  }
  
  /**
   Proceeds to attempt to work with the game server to create the new account
   
   Depending on whether and email address was provided, it invokes either:
   - checkForExisting(email)
   - confirmNoEmail()
   */
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
  
  /**
   Contacts the server to see if there is alredy an account with the requested
   email address.
   
   If email address is already in use, confirmDuplicateEmail(email) is invoked to prompt
   the user to confirm creating a second account with the same email address.
   
   If the email address is not currently in use, createAccount() is invoked.
   
   Note that it is possible for the game server request to fail:
   - If there is no response at all, a *failedToConnect* notification is sent to the *NotificationCenter*
   - If an invalid response was received, internalError() is invoked to ask user if they wish to report the issue
   */
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
          failedToConnectToServer()
          
        default: // includes .none (coding error) or Success (handled above)
          let err =  query.internalError ?? "Unknown Error"
          self.internalError(err , file:#file, function:#function)
        }
      }
    }
  }

  /**
   Prompts the user to confirm that they wish to create an account without an associated
   email address (and why they may want to reconsider).
   
   If the user confirms they don't want an associated email address, *createAccount()* is invoked.
   
   Otherwise, nothing happens and the create account modal simply stays in the forefront.
   */
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
  
  /**
   Prompts the user to select a course of action if an account already exists with the
   requested email address.
   
   The possible actions are:
   - Attempt to connect using the account associated with that email address
   - Request and email be sent to that email address with login information (username/password reset code)
   - Proceed to create a new account that will have the same associated email address
   - Go back to the create user modal popup to allow a different email address to be entered.
   */
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
  
  /**
   Requests the game server to create a new account based on the input.
   
   The game server will respond with either:
   - Success:  In this case, the *accountCreated* method is invoked to complete game setup and transition to the game view
   - User Exists: In this case, the *handleExistingUser* method is invoke to alert the user and give them the option to try to log into that account.
   
   Note that it is possible for the game server request to fail:
   - If there is no response at all, a *failedToConnect* notification is sent to the *NotificationCenter*
   - If an invalid response was received, internalError() is invoked to ask user if they wish to report the issue
   */
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
        case .FailedToConnect:
          failedToConnectToServer()
        case .Success(let data):
          self.accountCreated(username:username,alias:alias,email:email,data:data!)
        case .QueryFailure(GameQuery.Status.UserExists, _):
          self.handleExistingUser(username:username)
        default: // includes nil status
          let err =  query.internalError ?? "Unknown Error"
          self.internalError(err , file:#file, function:#function)
        }
    }
  }
  
  /**
   Constructs the local player based on data returned from the game server and dismisses the login view controller
   
   - Parameter username: username associated with the new account
   - Parameter alias: optional display name associated with the new account
   - Parameter email: optional email address associated with the new account
   - Parameter data: account data returned from the game server after creating the account
   */
  private func accountCreated(username:String, alias:String?, email:String?, data:HashData)
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
      LocalPlayer(userkey, data:data)
    
    self.infoPopup(title: "User Created", message: message) {
      self.loginVC.completed()
    }
  }
  
  /**
   Raises a confirmation dialog to alert the user that the requested username is already in use and offers the opportunity to attempt to log in with that account.
   
   - Parameter username: requested/existing username
   */
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
        Defaults.username = self.usernameTextField.text!
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
  /**
   Displays an information popup based on which field's info button was pressed.
   
   - Parameter sender: refernce to the (info) *UIButton* that was pressed.
   */
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
      
    case displayNameInfo:
      infoPopup(title: "Display Name", message: [
        "Specifying a display name is optional.",
        "If provided, this is the name that will be displayed to other players in the game.",
        "If you choose to specify a display name, it must be at least \(K.MinAliasLength) characters long.",
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
