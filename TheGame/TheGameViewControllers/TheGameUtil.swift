//
//  TheGameUtil.swift
//  TheGame
//
//  Created by Mike Mayer on 4/28/20.
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
                                debug("@@@ Add code to submit internal error:\n\(details)")
                                UserDefaults.standard.lastErrorEmail = now.localtime
                              } }
    }
  }
}

extension UserDefaults
{
  var username : String?
  {
    get { self.string(forKey: "username") }
    set {
      if let u = newValue, u.count > 0
      { self.set(u, forKey: "username") }
      else
      { self.removeObject(forKey: "username") }
    }
  }
  
  var userkey : String?
  {
    get { self.string(forKey: "userkey") }
    set {
      if let uk = newValue, uk.count > 0
      { self.set(uk, forKey: "userkey") }
      else
      { self.removeObject(forKey: "userkey") }
    }
  }
  
  var alias : String?
  {
    get { self.string(forKey: "alias") }
    set {
      if let a = newValue, a.count > 0
      { self.set(a, forKey: "alias") }
      else
      { self.removeObject(forKey: "alias") }
    }
  }
  
  var lastLoss : TimeInterval?
  {
    get { self.object(forKey: "LastLoss") as? TimeInterval }
    set {
      if let t = newValue { self.set(t,       forKey: "LastLoss") }
      else                { self.removeObject(forKey: "LastLoss") }
    }
  }
  
  var lastErrorEmail : TimeInterval
  {
    get { self.object(forKey: "lastErrorEmail") as? TimeInterval ?? 0.0 }
    set { self.set(newValue, forKey: "lastErrorEmail") }
  }
}
