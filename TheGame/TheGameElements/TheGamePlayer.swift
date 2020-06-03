//
//  TheGamePlayer.swift
//  TheGame
//
//  Created by Mike Mayer on 2/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FacebookLogin

fileprivate let iconSize     : CGFloat = 32.0
fileprivate let iconFontSize : CGFloat = 20.0

struct FacebookInfo
{
  let id             : String
  let name           : String
  let picture        : String? // URL of FB picture
  let friendsGranted : Bool
}

class TheGamePlayer
{
  let name : String
  let fb   : FacebookInfo?
  let icon : UIImage?
  
  var lastLoss : GameTime?
                 
  init(name:String, lastLoss : GameTime? = nil)
  {
    self.name = name
    self.fb   = nil
    self.lastLoss = lastLoss
    self.icon = TheGamePlayer.createIcon(for: name)
  }
  
  init(facebook:FacebookInfo, lastLoss : GameTime? = nil)
  {
    self.name = facebook.name
    self.fb   = facebook
    self.lastLoss = lastLoss
    self.icon = TheGamePlayer.createIcon(for: name, with: facebook.picture)
  }
  
  var lastLossString : String
  {
    if let t = lastLoss?.string { return t }
    else                        { return "No loss yet" }
  }
  
  func lost(after time:GameTime?) -> Bool
  {
    guard let lastLoss = lastLoss else { return false }
    guard let time     = time     else { return true  }
    return lastLoss > time
  }
  
  func lost(after other:TheGamePlayer) -> Bool
  {
    return lost(after:other.lastLoss)
  }
  
  static func createIcon(for name:String) -> UIImage
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
      UIBezierPath(ovalIn: box).fill()
      
      let initial = NSString(string:name).substring(to: 1)
      let x = NSAttributedString(string:initial, attributes:attr)
      var q = x.boundingRect(with: box.size, options: [], context: nil)
      q = q.offsetBy(dx: 0.5*(box.size.width - q.size.width),
                     dy: 0.5*(box.size.height - q.size.height)-q.origin.y)
      x.draw(in:q)
    }
    return image
  }
  
  static func createIcon(for name:String, with url:String?) -> UIImage
  {
    if let url = url,
      let imageURL = URL(string:url),
      let imageData = try? Data(contentsOf: imageURL),
      let image = UIImage(data: imageData)
    {
      let size = CGSize(width: iconSize, height: iconSize)
      let renderer = UIGraphicsImageRenderer(size: size)
      let icon = renderer.image { (_) in
        image.draw(in: CGRect.init(origin: CGPoint.zero, size: size))
      }
      return icon
    }
    return createIcon(for: name)
  }

}
