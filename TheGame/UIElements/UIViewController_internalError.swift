//
//  UIViewController_internalError.swift
//  TheGame
//
//  Created by Mike Mayer on 5/22/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension UIViewController
{
  func internalError(_ details:String..., file:String? = nil, line:Int? = nil, function:String? = nil)
  {
    var details = details.joined(separator: "\n")

    if var file = file {
      if let i = file.lastIndex(of: "/")  { file.removeSubrange(...i) }
      details.append("\nFile: \(file)")
      if let line = line { details.append("\nLine: \(line)") }
    }
    if let function = function { details.append("\nFunc: \(function)") }
    
    let now = GameTime()
    let lastErrorEmail = GameTime(networktime: UserDefaults.standard.lastErrorEmail)
    let nextErrorEmail = lastErrorEmail.offset(by: 3600.0)
        
    if now < nextErrorEmail  // only send one email per hour
    {
      self.infoPopup(title: "Internal Error", message: "Something went wrong");
    }
    else
    {
      self.confirmationPopup(title: "Internal Error",
                             message: [ "Something went wrong.", "Report the issue to VMWishes.com?" ],
                             ok: "Submit", cancel: "Not Now") { (submit) in
                              if submit {
                                TheGame.server.sendErrorReport(details)
                                UserDefaults.standard.lastErrorEmail = now.localtime
                              } }
    }
  }
}
