//
//  AccountLoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate var cachedUsername : String?

class AccountLoginViewController: ModalViewController
{
  var loginVC : LoginViewController?

  // MARK:- Subviews
  
  var username     : LoginTextField!
  var password     : LoginTextField!
  var passwordInfo : UIButton!
  
  var loginButton : UIButton!
  var cancelButton : UIButton!
  
  // MARK:- View State
  
  init(loginVC:LoginViewController? = nil)
  {
    self.loginVC = loginVC
    super.init(title: "Login")
  }
  
  required init?(coder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let loginDelegate = LoginTextFieldDelegate( { self.update() } )
    
    let usernameLabel = addHeader("Username", below: topMargin)
    username = addLoginEntry(below: usernameLabel, delegate: loginDelegate)
    
    let passwordLabel = addHeader("Password", below: username)
    password = addLoginEntry(below: passwordLabel, password: true, delegate: loginDelegate)
    passwordInfo = addInfoButton(to: password, target: self)

    
    let oops = UIButton(type: .system)
    managedView.addSubview(oops)
    oops.translatesAutoresizingMaskIntoConstraints = false
    oops.setTitle("Oops... I forgot my login info", for: .normal)
    oops.titleLabel?.font = UIFont.italicSystemFont(ofSize: 14)
    oops.alignCenterX(to: managedView)
    oops.attachTop(to: password,offset: Style.fieldGap)
    
    cancelButton = addCancelButton()
    loginButton  = addOkButton(title: "Connect")
    
    oops.addTarget(self, action: #selector(sendLoginInfo(_:)), for: .touchUpInside)
    loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
    
    cancelButton.attachTop(to: oops,offset: Style.contentGap)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    username.text = UserDefaults.standard.username ?? cachedUsername ?? ""
    password.text = ""

    update()
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)
    cachedUsername = username.text
  }
  
  // MARK:- Button Actions
  
  @objc func cancel(_ sender:UIButton)
  {
    loginVC?.cancel(self)
  }
  
  @objc func login(_ sender:UIButton)
  {
    debug("login")
  }
  
  @objc func sendLoginInfo(_ sender:UIButton)
  {
    container?.present(ModalControllerID.RetrieveLogin)
  }
  
  @discardableResult
  func update() -> Bool
  {
    let ok = (username.text?.count ?? 0) >= 6 && (password.text?.count ?? 0) >= 8
    loginButton.isEnabled = ok
    return ok
  }
}

extension AccountLoginViewController : InfoButtonDelegate
{
  func showInfo(_ sender: UIButton)
  {
    guard sender == passwordInfo else { return }
    
    self.infoPopup(title: "Password Rules", message: [
      "Must bea at least 8 characters long",
      "May only contain letters, numbers, or any of the following: - ! : # $ @ ."
    ])
  }
}
