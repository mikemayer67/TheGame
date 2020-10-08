//
//  TransferAccountLVC.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
Subclass of *ModalViewController* which displays the modal view for logging into an existing account
 using a transfer code that was requested from THIS device.
 
 This view controller should NOT be displayed if a request was not made from this device, i.e.
   there is no reset QCode (salt) value currently stored in the user defaults.  The app won't "break,"
   but there will be no way to successefully recover the player account
*/
class TransferAccountLVC: LoginModalViewController
{
  // MARK:- Subviews
  
  var transferCode  : UITextField!
  var transferInfo  : UIButton!
  var transferError : UILabel!
  
  var userCode  : UITextField!
  var userInfo  : UIButton!
  var userError : UILabel!
  
  var okButton      : UIButton!
  var cancelButton  : UIButton!
  
  var codeEntryDelegate : CodeEntryDelgate?
  
  // MARK:- View State
  
  init(loginVC:LoginViewController)
  {
    super.init(title: "Player Transfer", loginVC: loginVC)
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
    
    let transferLabel = addHeader("Transfer Code", below:titleRule)
    transferCode = addTextEntry(below: transferLabel, placeholder: "(received from game server)")
    transferInfo = addInfoButton(to:transferCode, target:self)
    transferError = addErrorLabel(to: transferInfo)
    
    let userLabel = addHeader("User Code", below:transferCode)
    userCode = addTextEntry(below: userLabel, placeholder: "(provided to game server)")
    userInfo = addInfoButton(to:userCode, target:self)
    userError = addErrorLabel(to: userInfo)
    
    cancelButton = addCancelButton()
    okButton  = addOkButton(title: "Transfer")
    
    cancelButton.attachTop(to:userCode, offset:Style.contentGap)
    
    transferCode.delegate = codeEntryDelegate
    userCode.delegate = codeEntryDelegate
    
    okButton.addTarget(self, action: #selector(transfer(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    transferCode.text = ""
    userCode.text = ""
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
    if !checkCode(transferCode,transferError) { ok = false }
    if !checkCode(userCode,userError) { ok = false }
    okButton.isEnabled = ok
    return ok
  }
  
  private func checkCode(_ codeField:UITextField, _ errorLabel:UILabel) -> Bool
  {
    var code = codeField.text ?? ""
    code.removeAll(where: { $0.isWhitespace })
        
    let delta = K.TransferCodeLength - code.count
    if delta > 0
    {
      errorLabel.text = "(\(delta))"
      errorLabel.isHidden = false
      return false
    }
    else
    {
      errorLabel.text = nil
      errorLabel.isHidden = true
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
  @objc func transfer(_ sender:UIButton)
  {
    if var scode = self.transferCode.text,
       var qcode = self.userCode.text
    {
      scode.removeAll( where: { $0.isWhitespace } )
      qcode.removeAll( where: { $0.isWhitespace } )

      LocalPlayer.connect(qcode: qcode, scode: scode) {
        (query, me) in
        if me != nil
        {
          TheGame.shared.me  = me
          self.infoPopup(title: "Welcome Back", message: "Your transfer was succesful. 👍", ok:"Excellent") {
            self.loginVC.completed()
          }
          return
        }
        // else... me is nil
        switch query.status
        {

        case .QueryFailure:
          self.infoPopup(title: "Sorry...", message: "Unrecognized Transfer/User Code Pairing")
          self.transferCode.text = ""
        case .FailedToConnect:
          failedToConnectToServer()
        default:
          let err =  query.internalError ?? "Unknown Error"
          self.internalError(err , file:#file, function:#function)
        }
      }
    }
  }
}





// MARK:- Info Button Delegate

extension TransferAccountLVC : InfoButtonDelegate
{
  /**
   Displays an information popup based on which field's info button was pressed.
   
   - Parameter sender: refernce to the (info) *UIButton* that was pressed.
   */
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case transferInfo:
      infoPopup(title: "Transfer Code", message: [
        "The code that was provided to you by the game server when you requested a transfer code."
      ])
    case userInfo:
      infoPopup(title: "User Code", message: [
        "The code that you provided to the game server when you requested a transfer code."
      ])
      
    default: break
    }
  }
}
