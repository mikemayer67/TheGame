//
//  ForgotLogin.swift
//  TheGame
//
//  Created by Mike Mayer on 5/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class ForgotLoginViewController: ModalViewController
{
  var loginVC : LoginViewController

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
    let passwordButton = addActionButton(title: "Retrieve Password", below: hr2)
    let hr3 = addHRule(below: passwordButton)
    let newAccountButton = addActionButton(title: "Create New Account", below: hr3)
    let hr4 = addHRule(below: newAccountButton)
    
    let cancel = addCancelButton()
    
    cancel.attachTop(to: hr4, offset: Style.textGap)
    
    cancel.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
    newAccountButton.addTarget(self, action: #selector(createNewAccount(_:)), for: .touchUpInside)
    usernameButton.addTarget(self, action: #selector(retrieveUsername(_:)), for: .touchUpInside)
    passwordButton.addTarget(self, action: #selector(retrievePassword(_:)), for: .touchUpInside)
  }

  // MARK:- Button Actions
  
  @objc func cancel(_ sender:UIButton)
  {
    mmvc?.present(.AccountLogin)
  }
  
  @objc func createNewAccount(_ sender:UIButton)
  {
    mmvc?.present(.CreateAccount)
  }
  
  @objc func retrieveUsername(_ sender:UIButton)
  {
    debug("retrieve username")
  }
  
  @objc func retrievePassword(_ sender:UIButton)
  {
    debug("retrieve password")
  }
}
