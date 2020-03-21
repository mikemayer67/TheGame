//
//  Alert.swift
//  TheGame
//
//  Created by Mike Mayer on 3/15/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum Alert
{
  case createAccountFailed(GameServerResponse)
  
  func display(over controller:UIViewController, animated:Bool = true)
  {
    var title   : String
    var message : String
    switch self
    {
    case let .createAccountFailed(details):
      title = "Sorry"
      message = "Failed to create a new user account.\n\n\(details)"
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    controller.present(alert,animated:animated)
  }
}
