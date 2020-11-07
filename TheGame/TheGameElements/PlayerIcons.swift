//
//  PlayerIcons.swift
//  TheGame
//
//  Created by Mike Mayer on 11/7/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

fileprivate let iconSize     : CGFloat = 32.0
fileprivate let iconFontSize : CGFloat = 18.0

func createIcon(for name:String) -> UIImage
{
  let renderer = UIGraphicsImageRenderer(size:CGSize(width:32,height:32));
  let image = renderer.image {
    c in
    
    let bg = UIColor(named:"playerIconBackgroud") ?? UIColor.black
    let fg = UIColor(named:"playerIconForeground") ?? UIColor.white
    
    let box = CGRect(x: 0.0, y: 0.0, width: iconSize, height: iconSize)
    let attr : Dictionary<NSAttributedString.Key,Any> = [
      .foregroundColor: fg ,
      .font: UIFont.systemFont(ofSize: iconFontSize, weight: .black)
    ]
    
    bg.setFill()
    UIBezierPath(rect: box).fill()
    
    let initial = String(name.capitalized.prefix(2))
    let x = NSAttributedString(string:initial, attributes:attr)
    var q = x.boundingRect(with: box.size, options: [], context: nil)
    q = q.offsetBy(dx: 0.5*(box.size.width - q.size.width),
                   dy: 0.5*(box.size.height - q.size.height)-q.origin.y)
    x.draw(in:q)
  }
  return image
}

func createIcon(for name:String, with url:String?) -> UIImage
{
  guard let url = url,
        let imageURL = URL(string:url),
        let imageData = try? Data(contentsOf: imageURL),
        let image = UIImage(data: imageData)
  else { return createIcon(for: name) }
  
  let size = CGSize(width: iconSize, height: iconSize)
  let renderer = UIGraphicsImageRenderer(size: size)
  
  let icon = renderer.image { (context) in
    let rect = CGRect.init(origin: CGPoint.zero, size: size)
    image.draw(in: CGRect.init(origin: CGPoint.zero, size: size))
    UIColor.black.setStroke()
    context.cgContext.setLineWidth(1.0)
    context.stroke(rect)
  }
  
  return icon
}

