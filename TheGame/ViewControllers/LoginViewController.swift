//
//  LoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum ViewEncodingError : Error
{
  case failedToDecode
}

class LoginViewController: UIViewController
{
  @IBOutlet weak var facebookButton : UIButton!
  @IBOutlet weak var newAccountButton : UIButton!
  @IBOutlet weak var loginButton : UIButton!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    let gs = GameServer.shared
  }
  
  @IBAction func connectWithFacebook(_ sender : UIButton)
  {
    performSegue(.FacebookLogin, sender: sender)
  }
  
  @IBAction func createNewAccount(_ sender : UIButton)
  {
    performSegue(.CreateAccount, sender: sender)
  }
  
  @IBAction func loginToAccount(_ sender : UIButton)
  {
    performSegue(.AccountLogin, sender: sender)
  }
  
  @IBAction func whyConnect(_ sender : UIButton)
  {
    InfoAlert.connectInfo.display(over: self)
  }
  
  @IBAction func returnToLogin(segue:UIStoryboardSegue)
  {}
  
  func update(animated:Bool) -> Void
  {
    debug("LoginViewController.update()")
    // @@@ TODO Check login status
  }
}
