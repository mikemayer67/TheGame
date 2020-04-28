//
//  InfoAlert.swift
//  TheGame
//
//  Created by Mike Mayer on 3/8/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit


enum InfoAlert : String
{
  case username    = "Username"
  case password    = "Password"
  case displayname = "Display Name"
  case email       = "Email"
  case connectInfo  = "Connection"
  
  func display(over controller:UIViewController, animated:Bool = true)
  {
    var message : String!
    switch self
    {
    case .username:
      message = "Your username must contain at least 8 characters.\n\nIt may contain any combination of letters and numbers"
      
    case .password:
      message = "Your password must contain at least 8 characters.\n\nIt may contain any combination of letters, numbers, or the following punctuation marks: - ! : # $ @ ."
      
    case .email:
      message = "Specifying your email is optional.\n\nIf provided, your email will only  be used to recover a lost username or password. It will not be used for any other purpose.\n\nIf you choose to not provide an email address, it won't be possible to recover your username or password if lost."
      
    case .displayname:
      message = "Specifying a display name is optional.\n\nIf provided, this is the name that will be displayed to other players in the game.\n\nIf you choose to specify a display name, it must be at least 8 characters long.\n\nIf you choose to not provide a display name, your username will be displayed to other players."
    }
    
    let alert = UIAlertController(title: self.rawValue, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    controller.present(alert,animated:animated)
  }
}
