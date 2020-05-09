//
//  GradientView.swift
//  MultiModalDemo
//
//  Created by Mike Mayer on 5/9/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView
{
  @IBInspectable var topColor    : UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
  @IBInspectable var bottomColor : UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
  @IBInspectable var midColor    : UIColor?
  
  var colors = [UIColor]() { didSet { buildGradient() } }
    
  init(frame:CGRect, colors:UIColor ...)
  {
    super.init(frame: frame)
    self.colors = colors
  }
  
  required init?(coder: NSCoder) { super.init(coder:coder) }
  
  override func awakeFromNib()
  {
    colors = [UIColor]()
    colors.append(topColor)
    if let mid = midColor { colors.append(mid) }
    colors.append(bottomColor)
  }
  
  override func layoutSubviews()
  {
    super.layoutSubviews()
    buildGradient()
  }
  
  private func buildGradient()
  {
    layer.sublayers?[0].removeFromSuperlayer()

    let cgColors = self.colors.map{ (c) -> CGColor in c.cgColor }

    let gradient = CAGradientLayer()
    gradient.frame = self.frame
    gradient.colors = cgColors
        
    layer.insertSublayer(gradient, at:0)
  }
}
