//
//  Segues.swift
//  TheGame
//
//  Created by Mike Mayer on 4/28/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension UIViewController
{
  enum SegueID : String
  {
    case createToLogin = "createToLogin"
    case createToRoot  = "createToRoot"
  }
  
  func performSegue(_ id: SegueID)
  {
    self.performSegue(withIdentifier: id.rawValue, sender: self)
  }
}
