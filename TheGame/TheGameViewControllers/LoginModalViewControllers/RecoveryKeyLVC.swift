//
//  RecoveryKeyLVC.swift
//  TheGame
//
//  Created by Mike Mayer on 5/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedEmail : String?

/**
 Subclass of *ModalViewController* which displays the modal view for requesting a recovery code
 by email.
 
 The game server will ONLY send the email if there is an account (or
 accounts) associated with that address.
*/
class RecoveryKeyLVC: LoginModalViewController
{
  var emailText   : UITextField!
  var emailInfo   : UIButton!
  var emailError  : UILabel!
  
  var okButton     : UIButton!
  var cancelButton : UIButton!
  
  // MARK:- View State
  
  init(loginVC:LoginViewController)
  {
    super.init(title: "Recovery Code Request",loginVC: loginVC)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) not supported")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()

    let emailLabel = addHeader("Email Address", below:titleRule)
    emailText = addTextEntry(below: emailLabel, placeholder:"email address", email: true)
    emailText.delegate = self
    emailInfo = addInfoButton(to: emailText, target: self)
    emailError = addErrorLabel(to: emailInfo)
    
    cancelButton = addCancelButton()
    okButton     = addOkButton(title:"Send Code")
    
    cancelButton.attachTop(to: emailText, offset: Style.contentGap)
    
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
    okButton.addTarget(self,action: #selector(sendCode(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    emailText.text = cachedEmail ?? ""
    checkAllAndUpdateState()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    cachedEmail = self.emailText.text
  }
  
  // MARK:- Input State

  /**
   Runs checks on each of the input fields.
   
   If any check fails, the create (OK) button is disabled.
   
   If all checks pass, the create button is enabled.
   */
  @discardableResult
  override func checkAllAndUpdateState() -> Bool
  {
    var allOK = true
    if !checkEmail() { allOK = false }
    okButton.isEnabled = allOK
    return allOK
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
    let t = (emailText.text ?? "").trimmingCharacters(in: .whitespaces)
    
    var err : String?
    
    if t.isEmpty
    {
      err = ""
    }
    else if t.range(of:K.emailRegex, options: .regularExpression) == nil
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
    self.mmvc?.rollback()
  }
  
  @objc func sendCode(_ sender:UIButton)
  {
    guard let email = emailText.text, !email.isEmpty else { return }
    debug("do it")
    
    TheGame.server.sendRecoveryCode(email: email) { (query) in
      switch query.status {
      case .Success(let data):
        let n = data?[QueryKey.CodeCount] as? Int ?? 1
        let qual = n>1 ? "\(n)" : "A"
        let s    = n>1 ? "s"    : ""
        let alert = UIAlertController(
          title: "Email sent",
          message: "\(qual) recovery code\(s) and instructions were sent to \(email)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                        (_) in self.mmvc?.present(.RecoverAccount) } ) )
        self.present(alert,animated: true)
        
      case .FailedToConnect:
        Defaults.hasRecoveryCode = false
        failedToConnectToServer()
        
      case .QueryFailure(GameQuery.Status.InvalidEmail, _):
        Defaults.hasRecoveryCode = false
        let alert = UIAlertController(
          title: "Invalid Email",
          message: "The email address \(email) is not recognized by TheGame", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert,animated: true)
        
      default: // includes nil status
        Defaults.hasRecoveryCode = false
        let err =  query.internalError ?? "Unknown Error"
        self.internalError(err , file:#file, function:#function)
      }
    }
  }
}

extension RecoveryKeyLVC : UITextFieldDelegate
{
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason)
  {
    startUpdateTimer(){ _ in self.checkAllAndUpdateState() }
  }
  
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool
  {
    startUpdateTimer(){ _ in self.checkAllAndUpdateState() }
    return true
  }
}

// MARK:- Info Button Delegate

extension RecoveryKeyLVC : InfoButtonDelegate
{
  /**
   Displays an information popup based on which field's info button was pressed.
   
   - Parameter sender: refernce to the (info) *UIButton* that was pressed.
   */
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case emailInfo:
      let device = UIDevice.current.model
      infoPopup(title:"Email", message: [
        "If you provided an email address to your game account, we can send you a code that will allow you to connect this \(device) to your account."
      ])
      
    default: break
    }
  }
}

