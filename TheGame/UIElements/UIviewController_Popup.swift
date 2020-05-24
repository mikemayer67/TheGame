//
//  UIViewController_Popups.swift
//  TheGame
//
//  Created by Mike Mayer on 5/22/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension UIViewController
{
  func infoPopup(title:String, message:[String], ok:String? = nil,
                 animated:Bool = true, completion:(()->Void)? = nil)
  {
    infoPopup(title: title,
              message: message.joined(separator: "\n\n"),
              ok: ok,
              animated: animated,
              completion:completion)
  }
  
  func infoPopup(title:String, message:String, ok:String? = nil,
                 animated:Bool = true, completion:(()->Void)? = nil)
  {
    let ok = ok ?? "OK"
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in completion?() } ) )
    self.present(alert,animated:animated)
  }
  
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
