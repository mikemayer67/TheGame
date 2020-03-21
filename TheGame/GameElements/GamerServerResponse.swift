//
//  GamerServerResponse.swift
//  TheGame
//
//  Created by Mike Mayer on 3/21/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum UserEmailStatus
{
  case NoEmail
  case HasValidatedEmail
  case HasUnvalidatedEmail
}

enum GameServerResponse
{
  case FailedToConnect
  case ServerError
  case UserCreated(String)      // userkey
  case UserAlreadyExists(UserEmailStatus)
  
  case NotYetImplemented // @@@ delete after all dev complete
}

extension GameServerResponse
{
  func displayAlert(over controller:UIViewController, animated:Bool = true)
  {
    var title   : String
    var message : String
    var actions : [UIAlertAction] = [
      UIAlertAction(title: "OK", style:.default, handler:nil),
      UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
    ]
    
    switch self
    {
    case .FailedToConnect:
      title = "Sorry"
      message = "Failed to connect to the game server.\n\nEnsure that you have network connectivity and try again later."
      
    case .ServerError:
      title = "Sorry"
      message = "Failed to recieve valid response from the game server.\n\nTry again later.\nIf this persists, please contact games@vmwishes.com"
      
    case .UserAlreadyExists:
      title = "User already exists"
      message = "\nIf this is you, please use the login page to reconnect.\n\nIf this is not you, you will need to select a different username."
      actions = [
        UIAlertAction(title: "Go to Login page", style:.default, handler:nil),
        UIAlertAction(title: "Enter new username", style:.default, handler:nil),
        UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
      ]
      
    case .NotYetImplemented:
      title = "NOT YET IMPLEMENTED"
      message = "Fix this before shipping..."
      
    default:
      return
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions.forEach { (action) in alert.addAction(action) }
    controller.present(alert,animated:animated)
  }
}
