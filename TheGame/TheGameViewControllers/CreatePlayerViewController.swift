//
//  CreatePlayerViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedName  : String?
fileprivate var cachedEmail : String?

/**
 Subclass of *ModalViewController* which displays the modal view for creating
 a new player
 */
class CreatePlayerViewController : ModalViewController
{
  var loginVC : LoginViewController
  
  private var updateTimer : Timer?
  
  //MARK:- Subviews
  
  var nameTextField   : UITextField!
  var nameInfo        : UIButton!
  var nameError       : UILabel!
  
  var emailTextField  : UITextField!
  var emailInfo       : UIButton!
  var emailError      : UILabel!
  
  var createButton    : UIButton!
  var cancelButton    : UIButton!
  
  // MARK:- View State
    
  init(loginVC:LoginViewController)
  {
    self.loginVC = loginVC
    super.init(title: "Player Info")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) not supported")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let nameLabel = addHeader("Display Name", below: titleRule, gap:Style.contentGap)
    nameTextField = addTextEntry(below: nameLabel, required: true)
    nameTextField.delegate = self
    nameInfo = addInfoButton(to:nameTextField, target:self)
    nameError = addErrorLabel(to: nameInfo)
    
    let emailLabel = addHeader("Email", below:nameTextField)
    emailTextField = addTextEntry(below: emailLabel, email: true)
    emailTextField.delegate = self
    emailInfo = addInfoButton(to: emailTextField, target: self)
    emailError = addErrorLabel(to: emailInfo)
    
    cancelButton = addCancelButton()
    createButton = addOkButton(title:"Let's Play")
    
    cancelButton.attachTop(to: emailTextField, offset: Style.contentGap)
    
    createButton.addTarget(self, action: #selector(create(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    nameTextField.text  = cachedName ?? ""
    emailTextField.text = cachedEmail ?? ""
    
    checkAllAndUpdateState()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    cachedName  = self.nameTextField.text
    cachedEmail = self.emailTextField.text
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
    if !checkName()  { allOK = false }
    if !checkEmail() { allOK = false }
    createButton.isEnabled = allOK
    return allOK
  }
  
  /**
   Verifies that the entered display name meets all requirements.
      
   Display name checks and corresponding error text:
   - not empty (*required*)
   - required minimum length (*too short*)
   
   - Returns: flag indicating if display name check passed
   */
  private func checkName() -> Bool
  {
    let t = (nameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    var err : String?
    
    if      t.isEmpty                 { err = "(required)" }
    else if t.count < K.MinNameLength { err = "too short"  }
    
    let ok = ( err == nil )
    nameError.text = err
    nameError.isHidden = ok
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
    guard checkAllAndUpdateState(), nameTextField.text != nil else { return }
    
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
   Contacts the server to see if there is alredy a player with the requested
   email address.
   
   If email address is already in use, confirmDuplicateEmail(email) is invoked to prompt
   the user to confirm creating a second player with the same email address.
   
   If the email address is not currently in use, createPlayer() is invoked.
   
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
        else      { self.createPlayer() }
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
   
   If the user confirms they don't want an associated email address, *createPlayer()* is invoked.
   
   Otherwise, nothing happens and the create account modal simply stays in the forefront.
   */
  private func confirmNoEmail()
  {
    let message = [
      "We respect your right to not provide an email address. It will not impact your ability to play TheGame.",
      "But you need to know that if you choose to proceed without one, you will not be able to recover your game history."
    ]
    
    confirmationPopup( title:"Proceed without Email", message:message, ok:"Proceed")
    { (proceed) in
      if proceed { self.createPlayer() }
    }
  }
  
  /**
   Prompts the user to select a course of action if an account already exists with the
   requested email address.
   
   The possible actions are:
   - Attempt to connect as player associated with that email address
   - Request an email be sent with a reconnection key
   - Proceed to create a new player that will have the same associated email address
   - Go back to the create player modal popup to allow a different email address to be entered.
   */
  private func confirmDuplicateEmail(_ email:String)
  {
    let alert = UIAlertController(
      title: "What do you want to do?",
      message: "The email address \(email) is associated with an existing player",
      preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "request reconnect key", style: .default, handler: { _ in
      self.mmvc?.present(.ReconnectKey)
    }))
    alert.addAction(UIAlertAction(title: "create new player anyway", style: .default, handler: { _ in
      self.createPlayer()
    }))
    alert.addAction(UIAlertAction(title: "try a different email", style: .cancel))
    
    self.present(alert,animated: true)
  }
  
  /**
   Requests the game server to create a new player based on the input.
   
   The only expected response from the game server is:
   - Success:  In this case, the *playerCreated* method is invoked to complete game setup and transition to the game view
   
   Note that it is possible for the game server request to fail:
   - If there is no response at all, a *failedToConnect* notification is sent to the *NotificationCenter*
   - If an invalid response was received, internalError() is invoked to ask user if they wish to report the issue
   */
  private func createPlayer()
  {
    guard checkAllAndUpdateState(), let name = nameTextField.text else { return }
    
    let email = emailTextField.text
    
    TheGame.server.requestNewPlayer(name: name, email: email ) {
      (query) in
      switch query.status {
      case .FailedToConnect:
        failedToConnectToServer()
      case .Success(let data):
        self.playerCreated(name:name, email:email, data:data!)
      default: // includes nil status
        let err =  query.internalError ?? "Unknown Error"
        self.internalError(err , file:#file, function:#function)
      }
    }
  }
  
  /**
   Constructs the local player based on data returned from the game server and dismisses the login view controller
   
   - Parameter name: Display name associated with the new account
   - Parameter email: optional email address associated with the new account
   - Parameter data: account data returned from the game server after creating the account
   */
  private func playerCreated(name:String, email:String?, data:HashData)
  {
    guard let userkey = data.userkey
      else { fatalError("query should have failed without userkey in the data") }
    
    var message = ["Dispaly name: \(name)"]

    if let email = email, email.count > 0 {
      message.append("Check your email for instructions on validating your email address.")
    }
    
    TheGame.shared.me =
      LocalPlayer(userkey, data:data)
    
    self.infoPopup(title: "Player Created", message: message) {
      self.loginVC.completed()
    }
  }
}

// MARK:- Text Field Delegate

extension CreatePlayerViewController : UITextFieldDelegate
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

extension CreatePlayerViewController : InfoButtonDelegate
{
  /**
   Displays an information popup based on which field's info button was pressed.
   
   - Parameter sender: refernce to the (info) *UIButton* that was pressed.
   */
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case nameInfo:
      infoPopup(title: "Display Name", message: [
        "This is the name that will be displayed to other players in the game.",
        "It must contain at least \(K.MinNameLength) characters not counting whitespace."
      ])
      
    case emailInfo:
      infoPopup(title:"Email", message: [
        "Specifying your email is optional.",
        "If provided, your email will only ever be used to reconnect you with your game history. Moreover, it will only be used at your request."
      ])
    default: break
    }
  }
}
