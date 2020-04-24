//
//  LoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController
{
  @IBOutlet weak var facebookButton : UIButton!
  @IBOutlet weak var newAccountButton : UIButton!
  @IBOutlet weak var loginButton : UIButton!
  @IBOutlet weak var whyConnect : UIButton!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    navigationController?.setNavigationBarHidden(true,animated:animated)
  }

  @IBAction func handleButton(_ sender : UIButton )
  {
    debug(sender)

    switch sender
    {
//    case newAccountButton: performSegue(.CreateAccount, sender: sender)
//    case loginButton:      performSegue(.AccountLogin,  sender: sender)
    case whyConnect:       InfoAlert.connectInfo.display(over: self)
    default:               break
    }
  }
  
  @IBAction func returnToLogin(segue:UIStoryboardSegue) {}
  
  func update(animated:Bool) -> Void
  {
    debug("LoginViewController.update()")
    // @@@ TODO Check login status
  }
}
