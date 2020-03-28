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
  case FacebookLogin          = "facebookLogin"
  case SwitchToFacebook       = "switchToFacebook"
  case SwitchToAccount        = "switchToAccount"
  case CreateAccountToLogin   = "createAccountToLogin"
  case AccountToLogin         = "accountToLogin"
  case FacebookToLogin        = "facebookToLogin"
  case UnwindToLogin          = "unwindToLogin"
}

extension UIViewController
{
//  func transition(to:TransitionTarget, direction:CATransitionSubtype)
//  {
//    if let nav = navigationController
//    {
//      let transition = CATransition()
//      transition.duration = 0.3
//      transition.type = .fade
//      transition.subtype = direction
//      nav.view.layer.add(transition, forKey: kCATransition)
//
//      let sc = nav.viewControllers[0]
//      let vc = nav.storyboard!.instantiateViewController(identifier: to.rawValue)
//
//      let newStack = ( sc == vc ? [sc] : [sc,vc] )
//
//      nav.pushViewController(vc, animated: false)
//      nav.setViewControllers(newStack, animated: false) // remove the login view controllers from the view stack
//    }
//  }
  
  func performSegue(_ target:SegueIdentifier, sender:Any?)
  {
    debug("performSegue:", target.rawValue)
    performSegue(withIdentifier: target.rawValue, sender: sender)
  }
}
