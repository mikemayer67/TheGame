//
//  CreateAccountViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController
{
  //MARK:- Outlets
  
  @IBOutlet weak var usernameTextField    : LoginTextField!
  @IBOutlet weak var password1TextField   : LoginTextField!
  @IBOutlet weak var password2TextField   : LoginTextField!
  @IBOutlet weak var displayNameTextField : UITextField!
  @IBOutlet weak var emailTextField       : UITextField!
  @IBOutlet weak var usernameError        : UILabel!
  @IBOutlet weak var passwordError        : UILabel!
  @IBOutlet weak var displayNameError     : UILabel!
  @IBOutlet weak var emailError           : UILabel!
  @IBOutlet weak var createButton         : UIButton!
  
  @IBOutlet weak var facebookInfoLabel    : UILabel!
  @IBOutlet weak var facebookButton       : UIButton!
    
  private var updateTimer : Timer?


  
  //MARK:- View State
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    navigationController?.setNavigationBarHidden(false, animated: animated)
    
    self.loginTextFieldUpdated(usernameTextField)
    self.loginTextFieldUpdated(password1TextField)
  }
  
  @IBAction func switchToFacebook(_ sender : UIButton)
  {
    performSegue(withIdentifier: "switchToFacebook", sender: sender)
  }
  
  @IBAction func displayInfo(_ sender:UIButton)
  {
    switch sender.tag
    {
    case 0: InfoAlert.username.display(over: self)
    case 1: InfoAlert.password.display(over: self)
    case 2: InfoAlert.displayname.display(over: self)
    case 3: InfoAlert.email.display(over: self)
    default: break
    }
  }
  
  @IBAction func createAccount(_ sender:UIButton)
  {
    guard checkAll() else { return }
    
    let email = emailTextField.text ?? ""
    
    if email.isEmpty
    {
      ConfirmationAlert.noEmail.display(over: self) { _ in self.requestNewAccount() }
    }
    else
    {
      requestNewAccount()
    }
  }
  
  func requestNewAccount()
  {
    print("request new account")
    self.showSpinner(onView: navigationController!.view)
    self.showSpinner(onView: self.view)
  }
  
  // MARK:- Input State
  
  func startupUpdateTimer()
  {
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in self.checkAll() }
  }
  
  @discardableResult
  func checkAll() -> Bool
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
    else if t1 != t2              { err = "failed confirmation" }
    
    let ok = ( err == nil )
    passwordError.text = err
    passwordError.isHidden = ok
    return ok
  }
  
  func checkDisplayName() -> Bool
  {
    let t = (displayNameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    
    var err : String?
    
    if t.count > 0, t.count<8 { err = "too short" }
    
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
}

extension CreateAccountViewController : LoginTextFieldDelegate, UITextFieldDelegate
{
  func loginTextFieldUpdated(_ sender:LoginTextField)
  {
    startupUpdateTimer()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
  {
    startupUpdateTimer()
    return true
  }
}
