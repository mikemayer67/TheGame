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
  /**
   Extends UIViewController to provide an easy means for reporting internal errors by email
   to the game development "team."
   
   It does not disply the details of the error to the user, but it does present a popup
   box to allow the user to determine whether or not the report should be sent.
   
   - Parameter details: Description of the error to be included in the report
   - Parameter file: Name of the file in which found the error (optional)
   - Parameter line: Line number in the file where error was found (optional)
   - Parameter function: Name of the function in which the error was found (optional)
   */
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
    let lastErrorEmail = GameTime(networktime: Defaults.lastErrorEmail)
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
                                Defaults.lastErrorEmail = now.localtime
                              } }
    }
  }
}
