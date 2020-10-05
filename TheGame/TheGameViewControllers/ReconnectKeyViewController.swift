//
//  ReconnectKeyViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 5/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
 Subclass of *ModalViewController* which displays the modal view for requesting a reconnection code
 by email.
 
 The game server will ONLY send the email if there is an account (or
 accounts) associated with that address.
*/
class ReconnectKeyViewController: ModalViewController
{
  var loginVC : LoginViewController
  
  var emailText   : UITextField?
  var validator   : TextFieldValidator?
  var okAction    : UIAlertAction?
  
  var cachedEmail : String?

  // MARK:- View State
  
  init(loginVC:LoginViewController)
  {
    self.loginVC = loginVC
    super.init(title: "Reconnect")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) not supported")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let header = addHeader("Let's see now.", below: titleRule)
    let subheader = addHeader("Do we have your email address?.", below: header, gap:0.0, indent:Style.entryIndent)
    
    let info1 = addInfoText("If so, we can send you your login information.",
                            below: subheader, gap: Style.fieldGap)
    let info2 = addInfoText("If not, your only option is to create a new player.",
                            below: info1, gap: Style.textGap)
    
    let hr1 = addHRule(below: info2, gap: Style.fieldGap)
    let requestButton = addActionButton(title: "Send Reconnect Code", below: hr1)
    let hr2 = addHRule(below: requestButton)
    let newAccountButton = addActionButton(title: "Create New Account", below: hr2)
    let hr3 = addHRule(below: newAccountButton)
    
    let cancel = addCancelButton()
    cancel.attachTop(to: hr3, offset: Style.textGap)
    
    cancel.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
    newAccountButton.addTarget(self, action: #selector(createNewAccount(_:)), for: .touchUpInside)
    requestButton.addTarget(self, action: #selector(getReconnecCode(_:)), for: .touchUpInside)
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
   Raises the popup dialog box requesting the address to which send the reconnect code email.
   
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
  @objc func getReconnecCode(_ sender:UIButton)
  {
    let popup = UIAlertController(
      title: "Retrieve Code",
      message: "Enter your email address.  " +
      "If there is an account associated with this address, a reconnection code and" +
      " additional instructions will be emailed to you.",
      preferredStyle: .alert)
        
    okAction = UIAlertAction(
      title: "OK",
      style: .default,
      handler: { (_) in
        if let email = self.emailText?.text, email.count > 0
        {
          self.cachedEmail = email
          TheGame.server.sendReconnectCode(email: email) { (query) in
            switch query.status {
            case .Success:
              let alert = UIAlertController(
                title: "Email sent",
                message: "A recover code and instructions were sent to \(email)", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (_) in self.loginVC.cancel() } ) )
              self.present(alert,animated: true)
              
            case .FailedToConnect:
              failedToConnectToServer()
              
            case .QueryFailure(GameQuery.Status.InvalidEmail, _):
              let alert = UIAlertController(
                title: "Invalid Email",
                message: "The email address \(email) is not recognized by TheGame", preferredStyle: .alert)
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
      self.emailText = textField
      textField.placeholder = "email"
      textField.text = self.cachedEmail ?? ""
      self.validator = TextFieldValidator(textfield: textField, action: self.okAction!)
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

extension ReconnectKeyViewController
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
    let textField : UITextField
    let action    : UIAlertAction
    
    init(textfield:UITextField, action:UIAlertAction)
    {
      self.textField = textfield
      self.action    = action
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
      if value.isEmpty { return false }
      if value.range(of:K.emailRegex, options:.regularExpression) == nil { return false }
      return true
    }
  }
}
