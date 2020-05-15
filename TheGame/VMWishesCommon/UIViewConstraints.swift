//
//  UIViewConstraints.swift
//  TheGame
//
//  Created by Mike Mayer on 5/13/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension UIView
{
  // MARK:- Horizontal Location
  
  func attachLeft(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.leftAnchor.constraint(equalTo: otherView.rightAnchor, constant: offset).isActive = true
  }
  
  func attachRight(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.rightAnchor.constraint(equalTo: otherView.leftAnchor, constant: -offset).isActive = true
  }
  
  func alignLeft(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.leftAnchor.constraint(equalTo: otherView.leftAnchor, constant: offset).isActive = true
  }
  
  func alignRight(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.rightAnchor.constraint(equalTo: otherView.rightAnchor, constant: -offset).isActive = true
  }
  
  func alignCenterX(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.centerXAnchor.constraint(equalTo: otherView.centerXAnchor, constant: offset).isActive = true
  }
  
  // MARK:- Vertical Location

  
  func attachTop(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.topAnchor.constraint(equalTo: otherView.bottomAnchor, constant: offset).isActive = true
  }
  
  func attachBottom(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.bottomAnchor.constraint(equalTo: otherView.topAnchor, constant: -offset).isActive = true
  }
  
  func alignTop(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.topAnchor.constraint(equalTo: otherView.topAnchor, constant: offset).isActive = true
  }
  
  func alignBottom(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: -offset).isActive = true
  }
  
  func alignCenterY(to otherView:UIView, offset:CGFloat = 0.0)
  {
    self.centerYAnchor.constraint(equalTo: otherView.centerYAnchor, constant: offset).isActive = true
  }
  
  // MARK:- Relative Size / Aspect Ratio
  
  func constrainWidth(to otherView:UIView, scale:CGFloat = 1.0)
  {
    self.widthAnchor.constraint(equalTo: otherView.widthAnchor, multiplier: scale).isActive = true
  }
  
  func constrainHeight(to otherView:UIView, scale:CGFloat = 1.0)
  {
    self.heightAnchor.constraint(equalTo: otherView.heightAnchor, multiplier: scale).isActive = true
  }
  
  func constraintAspectRatio(to otherView:UIView)
  {
    let ar = otherView.bounds.width / otherView.bounds.height
    self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: ar).isActive = true
  }
  
  // MARK:- Absolute Size / Aspect Ratio
  
  func constrainWidth(_ width:CGFloat)
  {
    self.widthAnchor.constraint(equalToConstant: width).isActive = true
  }
  func constrainHeight(_ height:CGFloat)
  {
    self.heightAnchor.constraint(equalToConstant: height).isActive = true
  }
  func constrainAspectRatio(_ aspectRatio:CGFloat)
  {
    self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: aspectRatio).isActive = true
  }
  
  func minWidth(_ width:CGFloat)
  {
    self.widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
  }
  
  func minHeight(_ height:CGFloat)
  {
    self.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
  }
 
  // MARK:- Composite Constraints
  
  func fill(view otherView:UIView, pad:CGFloat = 0.0)
  {
    fillX(view: otherView, pad: pad)
    fillY(view: otherView, pad: pad)
  }
  
  func fillX(view otherView:UIView, pad:CGFloat = 0.0)
  {
    alignLeft(to: otherView, offset:pad)
    alignRight(to: otherView, offset:pad)
  }
  
  func fillY(view otherView:UIView, pad:CGFloat = 0.0)
  {
    alignTop(to: otherView, offset:pad)
    alignBottom(to: otherView, offset:pad)
  }
  
  func alignCenter(to otherView:UIView)
  {
    alignCenterY(to: otherView)
    alignCenterX(to: otherView)
  }
  
  func constrainSize(width:CGFloat,height:CGFloat)
  {
    self.constrainWidth(width)
    self.constrainHeight(height)
  }
  
  func minSize(width:CGFloat,height:CGFloat)
  {
    self.minWidth(width)
    self.minHeight(height)
  }

  func packLeft(_ pad:CGFloat = 0.0)
  {
    if let sv = self.superview { self.alignLeft(to: sv, offset: pad) }
  }
  
  func packTop(_ pad:CGFloat = 0.0)
  {
    if let sv = self.superview { self.alignTop(to: sv, offset: pad) }
  }

  func packRight(_ pad:CGFloat = 0.0)
  {
    if let sv = self.superview { self.alignRight(to: sv, offset: pad) }
  }
  
  func packBottom(_ pad:CGFloat = 0.0)
  {
    if let sv = self.superview { self.alignBottom(to: sv, offset: pad) }
  }
    
}
