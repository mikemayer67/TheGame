//
//  UIViewController_Transition.swift
//  TheGame
//
//  Created by Mike Mayer on 3/21/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum TransitionTarget : String
{
  case Startup        = "startup"
  case CreateAccount  = "createAccount"
  case AccountLogin   = "accountLogin"
  case FacebookLogin  = "facebookLogin"
  case LoserBoard     = "loserBoard"
}

extension UIViewController
{
  func transition(to:TransitionTarget, direction:CATransitionSubtype)
  {
    if let nav = navigationController
    {
      let transition = CATransition()
      transition.duration = 0.3
      transition.type = .fade
      transition.subtype = direction
      nav.view.layer.add(transition, forKey: kCATransition)
      
      let sc = nav.viewControllers[0]
      let vc = nav.storyboard!.instantiateViewController(identifier: to.rawValue)
      
      let newStack = ( sc == vc ? [sc] : [sc,vc] )
      
      nav.pushViewController(vc, animated: false)
      nav.setViewControllers(newStack, animated: false) // remove the login view controllers from the view stack
    }
  }
}
