//
//  RecoverAccountLVC.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
Subclass of *ModalViewController* which displays the modal view for logging into an existing account
 using a recovery code that was requested from THIS device.
 
 This view controller should NOT be displayed if a request was not made from this device, i.e.
   there is no reset QCode (salt) value currently stored in the user defaults.  The app won't "break,"
   but there will be no way to successefully recover the player account
*/
class RecoverAccountLVC: LoginModalViewController
{
  // MARK:- Subviews
  
  var recoveryCode  : UITextField!
  var recoveryInfo  : UIButton!
  var recoveryError : UILabel!
  
  var okButton      : UIButton!
  var cancelButton  : UIButton!
  
  var codeEntryDelegate : CodeEntryDelgate?
  
  // MARK:- View State
  
  init(loginVC:LoginViewController)
  {
    super.init(title: "Player Recovery", loginVC: loginVC)
  }
  
  required init?(coder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    codeEntryDelegate = CodeEntryDelgate(
      onChange: { self.startUpdateTimer(){ _ in self.checkAllAndUpdateState() } }
    )
    
    let recoveryLabel = addHeader("Recovery Code", below:titleRule)
    recoveryCode = addTextEntry(below: recoveryLabel, placeholder: "(from email)")
    recoveryInfo = addInfoButton(to:recoveryCode, target:self)
    recoveryError = addErrorLabel(to: recoveryInfo)
    
    let resend = addActionButton(
      title: "Oops, I need a new code...",
      below: recoveryCode,
      gap: Style.fieldGap)
    
    cancelButton = addCancelButton()
    okButton  = addOkButton(title: "Reonnect")
    
    cancelButton.attachTop(to:resend, offset:Style.contentGap)
    
    recoveryCode.delegate = codeEntryDelegate
    
    resend.addTarget(self, action: #selector(resendRecoveryCode(_:)), for: .touchUpInside)
    okButton.addTarget(self, action: #selector(recover(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    recoveryCode.text = ""
    checkAllAndUpdateState()
  }
  
  // MARK:- Input State
  
  /**
   Runs checks on each of the input fields and updates.
   
   If any check fails, the login (OK) button is disabled.
   
   If all checks pass, the login button is enabled.
   */
  @discardableResult
  override func checkAllAndUpdateState() -> Bool
  {
    var ok = true
    if !checkRecoveryCode() { ok = false }
    okButton.isEnabled = ok
    return ok
  }
  
  private func checkRecoveryCode() -> Bool
  {
    var code = recoveryCode.text ?? ""
    code.removeAll(where: { $0.isWhitespace })
        
    let delta = K.RecoveryCodeLength - code.count
    if delta > 0
    {
      recoveryError.text = "(\(delta))"
      recoveryError.isHidden = false
      return false
    }
    else
    {
      recoveryError.text = nil
      recoveryError.isHidden = true
      return true
    }
  }
  
  // MARK:- Button Actions

  /// Simply dismisses the current modal view
  @objc func cancel(_ sender:UIButton)
  {
    loginVC.cancel()
  }
  
  /**
   Proceeds to attempt to work with the game server to recover the user account.
   
   The actual attempt to log in is made through *LocalPlayer*'s connect() method which will return the *GameQuery* transaction with the game server and a *LocalPlayer* reference.
   
   If either the connect codes are not recognized, the *LocalPlayer* reference will be nil.
   
   On success, the shared *TheGame* model is notified of the new *LocalPlayer* and the login view controller is dismissed.
   
   Note that it is possible for the game server request to fail:
   - If there is no response at all, a *failedToConnect* notification is sent to the *NotificationCenter*
   - If an invalid response was received, internalError() is invoked to ask user if they wish to report the issue
   */
  @objc func recover(_ sender:UIButton)
  {
    if var scode = self.recoveryCode.text
    {
      let qcode = Defaults.recoveryQCode
      
      scode.removeAll( where: { $0.isWhitespace } )

      LocalPlayer.connect(qcode: qcode, scode: scode) {
        (query, me) in
        if me != nil
        {
          TheGame.shared.me  = me
          self.infoPopup(title: "Welcome Back", message: "Your account recovery was succesful. 👍", ok:"Excellent") {
            self.loginVC.completed()
          }
          return
        }
        // else... me is nil
        switch query.status
        {

        case .QueryFailure:
          self.infoPopup(title: "Sorry...", message: "Unrecognized Recovery Code")
          self.recoveryCode.text = ""
        case .FailedToConnect:
          failedToConnectToServer()
        default:
          let err =  query.internalError ?? "Unknown Error"
          self.internalError(err , file:#file, function:#function)
        }
      }
    }
  }
  
  /**
   Raises the modal popup for requesting the game server to send an email
   to a given address with instructions for resetting a forgottern password.
   
   The game server will ONLY send the email if there is an account (or
   accounts) associated with that address.
   
   - Property sender: *UIButton* which triggered this action. [Ignored]
   */
  @objc func resendRecoveryCode(_ sender:UIButton)
  {
    mmvc?.present(.RecoveryKey)
  }
}

// MARK:- Info Button Delegate

extension RecoverAccountLVC : InfoButtonDelegate
{
  /**
   Displays an information popup based on which field's info button was pressed.
   
   - Parameter sender: refernce to the (info) *UIButton* that was pressed.
   */
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case recoveryInfo:
      let device = UIDevice.current.model
      infoPopup(title: "Recovery Code", message: [
        "Enter the recovery code that was emailed to you for this \(device).",
        "If you have lost the email or the code has expired, you can request a new one be sent."
      ])
      
    default: break
    }
  }
}
