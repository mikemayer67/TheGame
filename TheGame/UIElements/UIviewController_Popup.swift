//
//  UIViewController_Popups.swift
//  TheGame
//
//  Created by Mike Mayer on 5/22/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

// Adds extensions to all UIViewControllers that provides a means for easily bringing up
//  information or confirmation popups
extension UIViewController
{
  /**
   Wrapper around infoPopup that allows the message popup message to be expressed
   as an array of strings.  These strings will be seperated by a blank line in the
   popup view.
   - Parameters:
     - title: Message title
     - message: Array of strings used to build the message body
     - ok: String displayed in the "OK" button  [default="OK"]
     - animated: Flag indicating if the presentation of the popup should be animated [default=true]
     - completion: Completion handler invoked when OK button is pressed.
   The handler takes no arguments and returns no output. [optional]
   */
  func infoPopup(title:String, message:[String], ok:String? = nil,
                 animated:Bool = true, completion:(()->Void)? = nil)
  {
    infoPopup(title: title,
              message: message.joined(separator: "\n\n"),
              ok: ok,
              animated: animated,
              completion:completion)
  }
  
  /**
   Displays a popup view over the current view to display an information message.
   The only option available to the user is to dismiss the popup by clicking on
   the "OK" button.  A completion handler may be specified to respond to the
   dismissal of the popup.
   - Parameters:
     - title: Message title
     - message: Message body
     - ok: String displayed in the "OK" button  [default="OK"]
     - animated: Flag indicating if the presentation of the popup should be animated [default=true]
     - completion: Completion handler invoked when OK button is pressed.
   The handler takes no arguments and returns no output. [optional]
   */
  func infoPopup(title:String, message:String, ok:String? = nil,
                 animated:Bool = true, completion:(()->Void)? = nil)
  {
    let ok = ok ?? "OK"
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in completion?() } ) )
    self.present(alert,animated:animated)
  }
  
  /**
   Wrapper around confirmationPopup that allows the message popup message to be expressed
   as an array of strings.  These strings will be seperated by a blank line in the
   popup view.
   - Parameters:
     - title: Message title
     - message: Array of strings used to build the message body
     - ok: String displayed in the "OK" button  [default="OK"]
     - cancel: String displayed in the "cancel" button  [default="Cancel"]
     - animated: Flag indicating if the presentation of the popup should be animated [default=true]
     - completion: Completion handler invoked when OK button is pressed.
   The handler takes a single argument (*a bool indidating whether the user confirmed the action*)
   and returns no output. [optional]
   */
  func confirmationPopup(title:String, message:[String], ok:String? = nil, cancel:String? = nil,
                         animated:Bool = true, completion:((Bool)->Void)? = nil)
  {
    confirmationPopup(title: title,
                      message: message.joined(separator: "\n\n"),
                      ok:ok,
                      cancel:cancel,
                      animated:animated,
                      completion:completion)
  }
  
  /**
   Displays a popup view over the current view to display a message for the user
   to confirm.  The user may either accept the action by clicking on the "OK" button
   or decline the action by clicking on the "Cancel" button.  In either case, the
   popup will be immediately dismissed.  A completion handler may be specified to
   respond to the dismissal of the popup.
   - Parameters:
       - title: Message title
       - message: Message body
       - ok: String displayed in the "OK" button  [default="OK"]
       - cancel: String displayed in the "cancel" button  [default="Cancel"]
       - animated: Flag indicating if the presentation of the popup should be animated [default=true]
       - completion: Completion handler invoked when OK button is pressed.
     The handler takes a single argument (*a bool indidating whether the user confirmed the action*)
     and returns no output. [optional]
   */
  func confirmationPopup(title:String, message:String, ok:String? = nil, cancel:String? = nil,
                         animated:Bool = true, completion:((Bool)->Void)? = nil)
  {
    let ok = ok ?? "OK"
    let cancel = cancel ?? "Cancel"
    
    let alert = UIAlertController(title:title, message: message, preferredStyle:.alert)
    alert.addAction(UIAlertAction(title: cancel, style: .cancel,  handler: { _ in completion?(false) } ) )
    alert.addAction(UIAlertAction(title: ok,     style: .default, handler: { _ in completion?(true)  } ) )
    self.present(alert,animated: true)
  }
}
