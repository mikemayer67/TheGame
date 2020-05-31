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
  override func draw(_ rect: CGRect) {
    layer.borderWidth = ( isEnabled ? 1.0 : 0.0 )
    layer.borderColor = UIColor.black.cgColor
    layer.backgroundColor = self.isEnabled ? tintColor.cgColor : UIColor.lightGray.cgColor
    layer.cornerRadius = 10.0
  }
  
  override func tintColorDidChange() {
    layer.backgroundColor = self.isEnabled ? tintColor.cgColor : UIColor.lightGray.cgColor
  }
}
