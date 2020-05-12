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

class CreateAccountViewController : LoginModalViewController
{
  //MARK:- Outlets
  
  @IBOutlet weak var usernameTextField    : LoginTextField!
  @IBOutlet weak var password1TextField   : LoginTextField!
  @IBOutlet weak var password2TextField   : LoginTextField!
  @IBOutlet weak var displayNameTextField : UITextField!
  @IBOutlet weak var emailTextField       : UITextField!
  
  @IBOutlet weak var usernameInfo         : UIButton!
  @IBOutlet weak var passwordInfo         : UIButton!
  @IBOutlet weak var displayNameInfo      : UIButton!
  @IBOutlet weak var emailInfo            : UIButton!
  
  @IBOutlet weak var usernameError        : UILabel!
  @IBOutlet weak var passwordError        : UILabel!
  @IBOutlet weak var displayNameError     : UILabel!
  @IBOutlet weak var emailError           : UILabel!
  
  @IBOutlet weak var createButton         : UIButton!
  @IBOutlet weak var cancelButton         : UIButton!
  
  // MARK:- View State
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    managedView.layer.cornerRadius = 10
    managedView.layer.masksToBounds = true
    managedView.layer.borderColor = UIColor.gray.cgColor
    managedView.layer.borderWidth = 1.0
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    self.usernameTextField.text    = cachedUsername ?? ""
    self.password1TextField.text   = ""
    self.password2TextField.text   = ""
    self.displayNameTextField.text = cachedDisplayName ?? ""
    self.emailTextField.text       = cachedEmail ?? ""
    
    self.loginTextFieldUpdated(usernameTextField)
    self.loginTextFieldUpdated(password1TextField)
    
    navigationController?.setNavigationBarHidden(false,animated:animated)
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    cachedUsername    = self.usernameTextField.text
    cachedDisplayName = self.displayNameTextField.text
    cachedEmail       = self.emailTextField.text
  }
  
  // MARK:- IBActions
  
  @IBAction func handleButton(_ sender: UIButton)
  {
    switch sender
    {
    case usernameInfo:
      infoPopup(title: "Username", message: [
        "Your username must contain at least 8 characters.",
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
  
  @IBAction func createAccount(_ sender:UIButton)
  {
    guard checkAll() else { return }
    
    let email = emailTextField.text ?? ""
    
    if email.isEmpty
    {
      confirmationPopup(
        title:"Proceed without Email",
        message: [
          "Creating an account without an email address is acceptable.",
          "But if you choose to proceed without one, it might not be possible to recover your username or password if lost"
        ],
        ok:"Proceed")
      {
        (proceed) in if proceed { self.requestNewAccount() }
      }
    }
    else
    {
      requestNewAccount()
    }
  }

  // MARK:- Input State

  @discardableResult
  override func checkAll() -> Bool
  {
    var allOK = true
    if !checkUsername()    { allOK = false }
    if !checkPassword()    { allOK = false }
    if !checkDisplayName() { allOK = false }
    if !checkEmail()       { allOK = false }
    createButton.isEnabled = allOK
    return allOK
  }
  
  func checkUsername() -> Bool
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
  
  func checkPassword() -> Bool
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
  
  func checkDisplayName() -> Bool
  {
    let t = (displayNameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    var err : String?
    
    if t.count > 0, t.count<6 { err = "too short" }
    
    let ok = ( err == nil )
    displayNameError.text = err
    displayNameError.isHidden = ok
    return ok
  }
  
  func checkEmail() -> Bool
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

  
  func requestNewAccount()
  {
    guard let username = usernameTextField.text  else { return }
    guard let password = password1TextField.text else { return }
    
    // if all checks are working correctly, should always get here
    
    let alias = displayNameTextField.text ?? ""
    let email = emailTextField.text ?? ""
    
    var args : GameQueryArgs = [.Username:username, .Password:password]
    
    if alias.count > 0 { args[.Alias] = alias }
    if email.count > 0 { args[.Email] = email }
    
    TheGame.server.query(.User, action: .Create, gameArgs: args) {
      (response) in
            
      switch ( response.status, response.returnCode )
      {
      case (.FailedToConnect,_):
        if let lvc = self.loginVC { lvc.cancel(self, updateRoot: true) }
        else                      { self.dismiss(animated: true) }
        
      case (.InvalidURI,_), (.MissingCode,_):
        self.internalError(response.status.rawValue, file: #file, function: #function)
        
      case (.Success,.Success):
        
        if let userkey = response.userkey
        {
          var message = ["Username: \(username)"]
          if alias.count > 0 { message.append("Alias: \(alias)") }
          if email.count > 0 { message.append("Check your email for instructions on validating your email address") }
          
          UserDefaults.standard.userkey = userkey
          UserDefaults.standard.username = username
          UserDefaults.standard.alias = alias
          
          let me = LocalPlayer(userkey, username: username, alias: alias, gameData: response.data)
          TheGame.shared.me = me
          
          self.infoPopup(title: "User Created", message: message)
          {
            if let lvc = self.loginVC { lvc.completed(self) }
            else                      { self.dismiss(animated: true) }
          }
        }

      case (.Success,.UserExists):
        
        self.confirmationPopup(
          title: "User Exists",
          message: "Would you like to log in as \(self.usernameTextField.text!)?",
          ok: "Yes", cancel: "No", animated: true
        ) { (swithToLogin) in
          if swithToLogin
          {
            UserDefaults.standard.username = self.usernameTextField.text!
            self.container?.present(ViewControllerID.AccountLogin.rawValue)
          }
          else
          {
            self.usernameTextField.selectAll(self)
          }
        }
        
      default:
        
        var message : String
        if let  rc = response.rc { message = "Unexpected Game Server Return Code: \(rc)" }
        else                     { message = "Missing Response Code"                     }
        self.internalError( message, file:#file, function:#function )
      }
    }
  }
}
