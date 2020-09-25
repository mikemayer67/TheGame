//
//  GetConnectKeyViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 5/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
 Subclass of *ModalViewController* which displays the modal view for requesting an email with username or password reset information to a given email address.
 
 The game server will ONLY send the email if there is an account (or
 accounts) associated with that address.
*/
class GetConnectKeyViewController: ModalViewController
{
  var loginVC : LoginViewController
  
  var textField : UITextField?
  var validator : TextFieldValidator?
  var okAction  : UIAlertAction?
  
  var cachedEmail    : String?
  var cachedUsername : String?

  // MARK:- View State
  
  init(loginVC:LoginViewController)
  {
    self.loginVC = loginVC
    super.init(title: "Retrieve Login")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let header = addHeader("Don't Worry.", below: titleRule)
    let subheader = addHeader("It happens to the best of us.", below: header, gap:0.0, indent:Style.entryIndent)
    
    let info1 = addInfoText("If you included your email address in your account profile, we can send you your login information.",
                            below: subheader, gap: Style.fieldGap)
    let info2 = addInfoText("If not, your only option is to create a new account.",
                            below: info1, gap: Style.textGap)
    
    let hr1 = addHRule(below: info2, gap: Style.fieldGap)
    let usernameButton = addActionButton(title: "Retrieve Username", below: hr1)
    let hr2 = addHRule(below: usernameButton)
    let passwordButton = addActionButton(title: "Reset Password", below: hr2)
    let hr3 = addHRule(below: passwordButton)
    let newAccountButton = addActionButton(title: "Create New Account", below: hr3)
    let hr4 = addHRule(below: newAccountButton)
    
    let cancel = addCancelButton()
    
    cancel.attachTop(to: hr4, offset: Style.textGap)
    
    cancel.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
    newAccountButton.addTarget(self, action: #selector(createNewAccount(_:)), for: .touchUpInside)
    usernameButton.addTarget(self, action: #selector(retrieveUsername(_:)), for: .touchUpInside)
    passwordButton.addTarget(self, action: #selector(resetPassword(_:)), for: .touchUpInside)
  }

  // MARK:- Button Actions
  
  /// Simply dismisses the current modal view
  @objc func cancel(_ sender:UIButton)
  {
    mmvc?.rollback()
  }
  
  /// Switches to modal view for creating a new account
  @objc func createNewAccount(_ sender:UIButton)
  {
    mmvc?.present(.CreatePlayer)
  }
  
  /**
   Raises the popup dialog box requesting the address to which send the reminder email.
   
   There is a lot going on in the popup dialog box.
   
   - The email textfield content is validated using a *TextFieldValidator*. If the entry is not valid, the OK button is disabled.
   
   - The OK button is attached to an action which establishes the connection to the game server to request the email be sent.
   
   The game server can respond with either:
   - Success: In this case a popup will let the user know that the email was sent.
   - Invalid email: In this case, a popup will let the user know that there is no account associated with the requested email address.
   
   Note that it is possible for the game server request to fail:
   - If there is no response at all, a *failedToConnect* notification is sent to the *NotificationCenter*
   - If an invalid response was received, internalError() is invoked to ask user if they wish to report the issue
   */
  @objc func retrieveUsername(_ sender:UIButton)
  {
    cachedUsername = nil
    
    let popup = UIAlertController(
      title: "Retrieve Username",
      message: "Enter your email address.  " +
      "If there is an account associated with this address, your username and" +
      " password reset instructions will be emailed to you.",
      preferredStyle: .alert)
        
    okAction = UIAlertAction(
      title: "OK",
      style: .default,
      handler: { (_) in
        if let email = self.textField?.text, email.count > 0
        {
          self.cachedEmail = email
          TheGame.server.sendUsernameEmail(email: email) { (query) in
            switch query.status {
            case .Success:
              let alert = UIAlertController(
                title: "Email sent",
                message: "A username reminder and password reset instructions were sent to \(email)", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (_) in self.loginVC.cancel() } ) )
              self.present(alert,animated: true)
              
            case .FailedToConnect:
              failedToConnectToServer()
              
            case .QueryFailure(GameQuery.Status.InvalidEmail, _):
              let alert = UIAlertController(
                title: "Invalid Email",
                message: "The email address \(email) is not currently associated with a user account", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              self.present(alert,animated: true)
              
            default: // includes nil status
              let err =  query.internalError ?? "Unknown Error"
              self.internalError(err , file:#file, function:#function)
            }
          }
        }
    } )
    
    popup.addTextField { (textField) in
      self.textField = textField
      textField.placeholder = "email"
      textField.text = self.cachedEmail ?? ""
      self.validator = TextFieldValidator(
        textfield: textField, action: self.okAction!, type: .email
      )
      textField.delegate = self.validator
      textField.addTarget(
        self.validator,
        action: #selector(TextFieldValidator.textFieldValueChanged(_:)),
        for: .editingChanged
      )
      textField.clearButtonMode = .whileEditing
    }
    
    okAction?.isEnabled = false
    popup.addAction(okAction!)
    popup.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    self.present(popup,animated: true)
  }
  
  /**
   Raises the popup dialog box requesting the username of the account to which send the password reset email.
   
   There is a lot going on in the popup dialog box.
   
   - The username textfield content is validated using a *TextFieldValidator*. If the entry is not valid, the OK button is disabled.
   
   - The OK button is attached to an action which establishes the connection to the game server to request the email be sent.
   
   The game server can respond with either:
   - Success: In this case a popup will let the user know that the email was sent.
   - Invalid email: In this case, a popup will let the user know that there is no account associated with the specified username.
   
   Note that it is possible for the game server request to fail:
   - If there is no response at all, a *failedToConnect* notification is sent to the *NotificationCenter*
   - If an invalid response was received, internalError() is invoked to ask user if they wish to report the issue
   */
  @objc func resetPassword(_ sender:UIButton)
  {
    cachedEmail = nil
    
    let popup = UIAlertController(
      title: "Reset Password",
      message: "Enter your username.  " +
      "Your password reset instructions will be emailed to you.",
      preferredStyle: .alert)
    
    okAction = UIAlertAction(
      title: "OK",
      style: .default,
      handler: { (_) in
        if let username = self.textField?.text, username.count > 0
        {
          self.cachedUsername = username
          TheGame.server.sendPasswordResetEmail(username: username) { (query) in
            switch query.status {
            case .Success:
              let alert = UIAlertController(
                title: "Email sent",
                message: "Password reset instructions were sent to the email address associated with the username \(username)", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (_) in self.loginVC.cancel() } ) )
              self.present(alert,animated: true)
              
            case .FailedToConnect:
              failedToConnectToServer()
              
            case .QueryFailure(GameQuery.Status.InvalidUsername, _):
              let alert = UIAlertController(
                title: "Invalid Username",
                message: "The username \(username) is not currently associated with a user account", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              self.present(alert,animated: true)
              
            case .QueryFailure(GameQuery.Status.InvalidEmail, _):
                let alert = UIAlertController(
                  title: "No Email Address",
                  message: "The user account associated with the username \(username) does not have a verified email address associated with it", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert,animated: true)
            default: // includes nil status
              let err =  query.internalError ?? "Unknown Error"
              self.internalError(err , file:#file, function:#function)
            }
          }
        }
    })
    
    popup.addTextField { (textField) in
      self.textField = textField
      textField.placeholder = "username"
      textField.text = self.cachedUsername ?? ""
      self.validator = TextFieldValidator(
        textfield: textField, action: self.okAction!, type: .username
      )
      textField.delegate = self.validator
      textField.addTarget(
        self.validator,
        action: #selector(TextFieldValidator.textFieldValueChanged(_:)),
        for: .editingChanged
      )
      textField.clearButtonMode = .whileEditing
    }
    
    okAction?.isEnabled = false
    popup.addAction(okAction!)
    popup.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    self.present(popup,animated: true)
  }
}

extension GetConnectKeyViewController
{
  /**
   Implements a UITextFieldDelegate for the purpose of validating the
   structure of the data in a *UITextField*.
   
   The text can be validated as either a username or as an email address.
   
   The *textFieldShouldReturn* and *textFiedValueChanged* methods are implmented in this delegate.
   - Response to the return key is disabled unless the *UITextField* content is valid.
   - Whenever the content of the *UITextField* changes, it is evaluated and the specified alert action is enabled/disabled accordingly.
   
   The concept for this class was derived from https://gist.github.com/ole/f76630731c9a0cda90bb6bae28e82927
   */
  class TextFieldValidator : NSObject, UITextFieldDelegate
  {
    enum ValidationType { case username; case email }
    
    let textField : UITextField
    let type      : ValidationType
    let action    : UIAlertAction
    
    init(textfield:UITextField, action:UIAlertAction, type:ValidationType)
    {
      self.textField = textfield
      self.action    = action
      self.type      = type
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
      return isValid(textField.text ?? "")
    }
    
    @objc func textFieldValueChanged(_ sender:UITextField)
    {
      action.isEnabled = isValid(textField.text ?? "")
    }
    
    func isValid(_ value:String) -> Bool
    {
      switch type
      {
      case .username:
        if value.count < K.MinUsernameLength { return false }
        
        let disallowed = CharacterSet.alphanumerics.inverted
        if value.rangeOfCharacter(from: disallowed) != nil { return false }
        
        return true
        
      case .email:
        if value.isEmpty { return false }
        
        if value.range(of:K.emailRegex, options:.regularExpression) == nil { return false }
        
        return true
      }
    }
  }
}
