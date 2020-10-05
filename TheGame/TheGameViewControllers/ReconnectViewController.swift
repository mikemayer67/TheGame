//
//  ReconnectViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
Subclass of *ModalViewController* which displays the modal view for logging into an existing account
 using a reconnect code that was requested from THIS device.
 
 This view controller should NOT be displayed if a request was not made from this device, i.e.
   there is no reset QCode (salt) value currently stored in the user defaults.  The app won't "break,"
   but there will be no way to successefully reconnect to the server
*/
class ReconnectViewController: ModalViewController
{
  var loginVC : LoginViewController
  
  private var updateTimer : Timer?

  // MARK:- Subviews
  
  var reconnectCode  : LoginTextField!
  var reconnectInfo  : UIButton!
  var reconnectError : UILabel!
  
  var okButton       : UIButton!
  var cancelButton   : UIButton!
  
  // MARK:- View State
  
  init(loginVC:LoginViewController)
  {
    self.loginVC = loginVC
    super.init(title: "Reconnect")
  }
  
  required init?(coder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let reconnectLabel = addHeader("Reset Code", below:titleRule)
    reconnectCode = addLoginEntry(below: reconnectLabel, type:.ResetCode)
    reconnectCode.changeCallback = { self.startUpdateTimer() }
    reconnectInfo = addInfoButton(to:reconnectCode, target:self)
    reconnectError = addErrorLabel(to: reconnectInfo)
    
    let resend = addActionButton(
      title: "Oops, I need a new code...",
      below: reconnectCode,
      gap: Style.fieldGap)
    
    cancelButton = addCancelButton()
    okButton  = addOkButton(title: "Reonnect")
    
    cancelButton.attachTop(to:resend, offset:Style.contentGap)
    
    resend.addTarget(self, action: #selector(resendConnectCode(_:)), for: .touchUpInside)
    okButton.addTarget(self, action: #selector(reconnect(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    reconnectCode.text = ""
    checkAllAndUpdateState()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    // ok, not needed, but provided for consistency
    super.viewWillDisappear(animated)
  }
  
  // MARK:- Input State
  
  /**
   Runs checks on each of the input fields and updates.
   
   If any check fails, the login (OK) button is disabled.
   
   If all checks pass, the login button is enabled.
   */
  @discardableResult
  func checkAllAndUpdateState() -> Bool
  {
    var ok = true
    if !checkReconnectCode() { ok = false }
    okButton.isEnabled = ok
    return ok
  }
  
  private func checkReconnectCode() -> Bool
  {
    var code = reconnectCode.text ?? ""
    code.removeAll(where: { $0.isWhitespace })
    
    var err : String?
    
    if code.isEmpty { err = "(required)" }
    else if code.count < K.ResetCodeLength { err = "too short" }
    else if code.count > K.ResetCodeLength { err = "too long" }
    
    let ok = ( err == nil )
    reconnectError.text = err
    reconnectError.isHidden = ok
    return ok
  }
  
  func startUpdateTimer()
  {
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false)
    { _ in self.checkAllAndUpdateState() }
  }
  
  // MARK:- Button Actions

  /// Simply dismisses the current modal view
  @objc func cancel(_ sender:UIButton)
  {
    loginVC.cancel()
  }
  
  /**
   Proceeds to attempt to work with the game server to reconnect to the user account.
   
   The actual attempt to log in is made through *LocalPlayer*'s connect() method which will return the *GameQuery* transaction with the game server and a *LocalPlayer* reference.
   
   If either the connect codes are not recognized, the *LocalPlayer* reference will be nil.
   
   On success, the shared *TheGame* model is notified of the new *LocalPlayer* and the login view controller is dismissed.
   
   Note that it is possible for the game server request to fail:
   - If there is no response at all, a *failedToConnect* notification is sent to the *NotificationCenter*
   - If an invalid response was received, internalError() is invoked to ask user if they wish to report the issue
   */
  @objc func reconnect(_ sender:UIButton)
  {
    if let scode = self.reconnectCode.text
    {
      let qcode = Defaults.reconnectQCode

      LocalPlayer.connect(qcode: qcode, scode: scode) {
        (query, me) in
        if me != nil
        {
          TheGame.shared.me  = me
          self.loginVC.completed()
          return
        }
        // else... me is nil
        switch query.status
        {

        case .QueryFailure:
          self.infoPopup(title: "Failed to Connect", message: "Unrecognized Reconnect Code")
          self.reconnectCode.text = ""
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
  @objc func resendConnectCode(_ sender:UIButton)
  {
    mmvc?.present(.ReconnectKey)
  }
}

// MARK:- Info Button Delegate

extension ReconnectViewController : InfoButtonDelegate
{
  /**
   Displays an information popup based on which field's info button was pressed.
   
   - Parameter sender: refernce to the (info) *UIButton* that was pressed.
   */
  func showInfo(_ sender: UIButton)
  {
    switch sender
    {
    case reconnectInfo:
      infoPopup(title: "Reconnect Code", message: [
        "Enter the reconnect code that was emailed to you.",
        "If you have not yet requested a code, if you've lost the email, or the code has expired, you can request a reconnect code now using the link below."
      ])
      
    default: break
    }
  }
}
