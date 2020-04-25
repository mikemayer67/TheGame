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

  @IBAction func whyFacebook(_ sender : UIButton)
  {
    InfoAlert.connectInfo.display(over:self)
  }
  
  @IBAction func returnToLogin(segue:UIStoryboardSegue) {}
}
