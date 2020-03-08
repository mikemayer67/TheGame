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
  @IBOutlet weak var usernameError        : UILabel!
  @IBOutlet weak var passwordError        : UILabel!
  @IBOutlet weak var emailError           : UILabel!
  @IBOutlet weak var displayNameTextField : UITextField!
  @IBOutlet weak var emailTextField       : UITextField!
  @IBOutlet weak var createButton         : UIButton!
  
  @IBOutlet weak var facebookInfoLabel    : UILabel!
  @IBOutlet weak var facebookButton       : UIButton!
  
  //MARK:- View State
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    navigationController?.setNavigationBarHidden(false, animated: animated)
    
    self.loginTextFiledUpdated(usernameTextField)
    self.loginTextFiledUpdated(password1TextField)
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
  
  // MARK:- Input State
  
  func setUsernameError(_ err:String)
  {
    usernameError.text = err
    usernameError.isHidden = false
    createButton.isEnabled = false
  }
  func clearUsernameError()
  {
    usernameError.isHidden = true
    createButton.isEnabled = passwordError.isHidden && emailError.isHidden
  }
  
  func setPasswordError(_ err:String)
  {
    passwordError.text = err
    passwordError.isHidden = false
    createButton.isEnabled = false
  }
  func clearPasswordError()
  {
    passwordError.isHidden = true
    createButton.isEnabled = usernameError.isHidden && emailError.isHidden
  }
  
  func setEmailError(_ err:String)
  {
    emailError.text = err
    emailError.isHidden = false
    createButton.isEnabled = false
  }
  func clearEmailError()
  {
    emailError.isHidden = true
    createButton.isEnabled = usernameError.isHidden && passwordError.isHidden
  }
}

extension CreateAccountViewController : LoginTextFieldDelegate
{
  func loginTextFiledUpdated(_ sender:LoginTextField)
  {
    let t = sender.text ?? ""
    if( sender == usernameTextField )
    {
      if      t.isEmpty   { setUsernameError("(required)") }
      else if t.count < 6 { setUsernameError("too short")  }
      else                { clearUsernameError()           }
    }
    else if( sender == password1TextField || sender == password2TextField )
    {
      let t2 = (sender == password1TextField ? password2TextField : password1TextField).text ?? ""
      if      t.isEmpty || t2.isEmpty  { setPasswordError("(required)") }
      else if t.count < 8              { setPasswordError("too short")  }
      else if t != t2                  { setPasswordError("mismatched") }
      else                             { clearPasswordError()           }
    }
  }
}
