//
//  ConfirmationAlert.swift
//  TheGame
//
//  Created by Mike Mayer on 3/8/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum ConfirmationAlert : String
{
  case noEmail = "Proceed without Email?"
  
  func display(over controller:UIViewController, action:((UIAlertAction)->Void)? )
  {
    var message : String!
    var okString = "OK"
    var cancelString = "Cancel"
    switch self
    {
    case .noEmail:
      message = "Creating an account without an email address is acceptable.\n\nBut if you choose to proceed without one, it might not be possible to recover your username or password if lost"
      okString = "Proceed"
    }
    
    let alert = UIAlertController(title:self.rawValue, message: message, preferredStyle:.alert)
    alert.addAction(UIAlertAction(title:cancelString, style: .cancel, handler:nil))
    alert.addAction(UIAlertAction(title: okString, style: .default, handler: action))
    controller.present(alert,animated: true)
  }
}
