//
//  GamerServerAlert.swift
//  TheGame
//
//  Created by Mike Mayer on 3/21/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

protocol GameServerAlertObserver
{
  func ok()
  func cancel()
  func goToLogin()
}

extension GameServerResponse
{
  func displayAlert(over controller:UIViewController, observer:GameServerAlertObserver? = nil)
  {
    var title   : String
    var message : String
    var actions : [UIAlertAction] = [
      UIAlertAction(title: "OK", style: .default, handler: { _ in observer?.ok() } ),
      UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in observer?.cancel() } )
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
        UIAlertAction(title: "Go to Login page",   style: .default, handler: { _ in observer?.goToLogin() } ),
        UIAlertAction(title: "Enter new username", style: .default, handler: { _ in observer?.ok() } ),
        UIAlertAction(title: "Cancel",             style: .cancel,  handler: { _ in observer?.cancel() } )
      ]
      
    case .NotYetImplemented:
      title = "NOT YET IMPLEMENTED"
      message = "Fix this before shipping..."
      
    default:
      return
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions.forEach { (action) in alert.addAction(action) }
    controller.present(alert,animated:true)
  }
}
