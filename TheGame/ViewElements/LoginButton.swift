//
//  LoginButton.swift
//  TheGame
//
//  Created by Mike Mayer on 3/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

@IBDesignable class LoginButton: UIButton
{
  @IBInspectable var buttonColor : UIColor = UIColor.blue
  
  override func draw(_ rect: CGRect) {
    layer.borderWidth = 1.0
    layer.backgroundColor = buttonColor.cgColor
    layer.borderColor = UIColor.black.cgColor
    layer.cornerRadius = 10.0
  }

}
