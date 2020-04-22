//
//  UIViewController_Segues.swift
//  TheGame
//
//  Created by Mike Mayer on 3/21/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum SegueIdentifier : String
{
  case CreateAccount          = "createAccount"
  case AccountLogin           = "accountLogin"
  case SwitchToAccount        = "switchToAccount"
  case CreateAccountToLogin   = "createAccountToLogin"
  case AccountToLogin         = "accountToLogin"
}

extension UIViewController
{
  func performSegue(_ target:SegueIdentifier, sender:Any?)
  {
    performSegue(withIdentifier: target.rawValue, sender: sender)
  }
}
