//
//  Opponent.swift
//  TheGame
//
//  Created by Mike Mayer on 6/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FacebookLogin

fileprivate let iconSize     : CGFloat = 32.0
fileprivate let iconFontSize : CGFloat = 18.0

struct FacebookInfo
{
  let fbid           : String
  let name           : String
  let picture        : String? // URL of FB picture
  let friendsGranted : Bool
  
  init(fbid:String, name:String, picture:String?, friendsGranted:Bool = false)
  {
    self.fbid = fbid
    self.name = name
    self.picture = picture
    self.friendsGranted = friendsGranted
  }
}

class Opponent : Participant, Comparable
{
  let name : String
  let fb   : FacebookInfo?
  let icon : UIImage?
  let matchID : Int
  var matchStart : GameTime
  var lastPoke : GameTime?
  
  init(name:String, matchID:Int, matchStart:GameTime, lastLoss:GameTime? = nil)
  {
    self.name       = name
    self.fb         = nil
    self.icon       = createIcon(for:name)
    self.matchID    = matchID
    self.matchStart = matchStart
    self.lastPoke   = nil
    super.init(lastLoss:lastLoss)
  }
  
  init(facebook:FacebookInfo, matchID:Int, matchStart:GameTime, lastLoss:GameTime? = nil)
  {
    self.name       = facebook.name
    self.fb         = facebook
    self.icon       = createIcon(for:name, with:facebook.picture)
    self.matchID    = matchID
    self.matchStart = matchStart
    super.init(lastLoss:lastLoss)
  }
    
  static func < (lhs: Opponent, rhs: Opponent) -> Bool
  {
    return rhs.lost(after: lhs.lastLoss)
  }
  
  static func == (lhs: Opponent, rhs: Opponent) -> Bool
  {
    if lhs.lost(after:rhs) { return false }
    if rhs.lost(after:lhs) { return false }
    return true
  }
}
  
fileprivate func createIcon(for name:String) -> UIImage
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

fileprivate func createIcon(for name:String, with url:String?) -> UIImage
{
  if let url = url,
    let imageURL = URL(string:url),
    let imageData = try? Data(contentsOf: imageURL),
    let image = UIImage(data: imageData)
  {
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
  else
  {
    return createIcon(for: name)
  }
}
