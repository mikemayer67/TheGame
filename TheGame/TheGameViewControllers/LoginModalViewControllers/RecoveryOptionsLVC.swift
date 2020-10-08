//
//  RecoveryOptionsLVC.swift
//  TheGame
//
//  Created by Mike Mayer on 10/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
 Subclass of *ModalViewController which displays the options for recovering an
 existing account when no recovery code has been requested from the current device.
 */

class RecoveryOptionsLVC: LoginModalViewController
{
  init(loginVC:LoginViewController)
  {
    super.init(title: "Recovery Options", loginVC: loginVC)
  }
  
  required init?(coder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
        
    var recoveryButton  : UIButton?
    var resendButton    : UIButton!
    var transferButton  : UIButton!
        
    let header = addHeader("Let's see what we can do...", below: titleRule)
    
    let device = UIDevice.current.model

    if Defaults.hasRecoveryCode
    {
      let recoveryInfo = addInfoText(
        "If you received an email with the recovery code for this \(device):",
        below: header, gap: Style.headerGap, font: Style.textFont)
      
      recoveryButton = addActionButton(title:"Enter Recovery Code", below:recoveryInfo)
            
      let resendInfo = addInfoText(
        "If we have your email address and you would like to request a new recovery code:",
        below: recoveryButton!, gap: Style.textGap, font: Style.textFont)
      
      resendButton = addActionButton(title:"Request New Recovery Code", below:resendInfo)
    }
    else
    {
      let resendInfo = addInfoText(
        "If we have your email address and you would like to request a recovery code for this \(device):",
        below: header, gap: Style.headerGap, font: Style.textFont)
      
      resendButton = addActionButton(title:"Request Recovery Code", below:resendInfo)
    }
        
    let transferInfo = addInfoText(
      "If your requested a transfer code from another iPhone or iPad:",
      below: resendButton, gap: Style.textGap, font: Style.textFont)
    
    transferButton = addActionButton(title:"Enter Transfer Code", below:transferInfo)
    
    let otherwiseInfo = addInfoText(
      "Otherwise, you are going to need to log in with Facebook or create a new player",
      below:transferButton, gap:Style.textGap, font: Style.textFont)
    
    let cancel = addCancelButton()
    cancel.attachTop(to: otherwiseInfo, offset: Style.textGap)
    
    cancel.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
    recoveryButton?.addTarget(self, action: #selector(recoverAccount(_:)), for: .touchUpInside)
    resendButton.addTarget(self, action: #selector(sendRecoveryCode(_:)), for: .touchUpInside)
    transferButton.addTarget(self, action: #selector(transfer(_:)), for: .touchUpInside)

  }
  
  // MARK:- Button Actions
  
  /// Simply dismisses the current modal view
  @objc func cancel(_ sender:UIButton)
  {
    self.dismiss(animated: true)
  }
  
  @objc func recoverAccount(_ sender:UIButton)
  {
    self.mmvc?.present(.RecoverAccount)
  }
  
  @objc func sendRecoveryCode(_ sender:UIButton)
  {
    self.mmvc?.present(.RecoveryKey)
  }
  
  @objc func transfer(_ sender:UIButton)
  {
    self.mmvc?.present(.TransferAccount)
  }
}
