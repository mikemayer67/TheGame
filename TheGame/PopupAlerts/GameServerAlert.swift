//
//  GameServerAlert.swift
//  TheGame
//
//  Created by Mike Mayer on 3/21/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension QueryResponse
{
  typealias Callback = () -> ()
  func displayAlert(over controller:UIViewController,
                    ok: Callback?,
                    cancel: Callback?,
                    action: Callback? )
  {
    var title   : String
    var message : String
    var actions : [UIAlertAction] = [
      UIAlertAction(title: "OK", style: .default, handler: { _ in ok?() } ),
      UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in cancel?() } )
    ]
    
    switch self.returnCode
    {
    case .FailedToConnect:
      title = "Sorry"
      message = "Failed to connect to the game server.\n\nEnsure that you have network connectivity and try again later."
      
    case .UserExists:
      title = "User already exists"
      message = "\nIf this is you, please use the login page to reconnect.\n\nIf this is not you, you will need to select a different username."
      actions = [
        UIAlertAction(title: "Go to Login page",   style: .default, handler: { _ in action?() } ),
        UIAlertAction(title: "Enter new username", style: .default, handler: { _ in ok?() } ),
        UIAlertAction(title: "Cancel",             style: .cancel,  handler: { _ in cancel?() } )
      ]
      
    default:
      return
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions.forEach { (action) in alert.addAction(action) }
    controller.present(alert,animated:true)
  }
}
