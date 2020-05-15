//
//  InfoButton.swift
//  TheGame
//
//  Created by Mike Mayer on 5/15/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit



class InfoButton
{
  private(set) var button : UIButton
  var              title  : String
  var              info   : String
  
  init(_ title: String, _ info : String)
  {
    self.title = title
    self.info = info
    button = UIButton(type: .infoLight)
    button.addTarget(self, action: #selector(showInfo(_:)), for: .touchUpInside)
  }
  
  convenience init(_ title: String, _ info : [String] )
  {
    self.init(title, info.joined(separator: "\n\n") )
  }
  
  @objc func showInfo(_ sender:UIButton)
  {
    if let vc = button.inputViewController
    {
      vc.infoPopup(title: title, message: info)
    }
  }
}
