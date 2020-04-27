//
//  Opponent.swift
//  TheGame
//
//  Created by Mike Mayer on 2/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation
import UIKit

class Opponent : Player, Comparable
{
  let image      : UIImage
  let matchStart : GameTime
  
  init(key:String, name:String, fb:FBUserInfo? = nil, matchStart:GameTime, lastLoss:GameTime? = nil)
  {
    self.matchStart = matchStart
    self.image = Opponent.image(for:name)

    super.init(key:key, name:name, fb:fb, lastLoss:lastLoss)
  }
  
  static func image(for name:String) -> UIImage
  {
    let renderer = UIGraphicsImageRenderer(size:CGSize(width:32,height:32));
    let image = renderer.image {
      c in
      
      let box = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
      let attr : Dictionary<NSAttributedString.Key,Any> = [
        .foregroundColor: UIColor.white ,
        .font: UIFont.systemFont(ofSize: 20.0, weight: .black)
      ]
      
      UIColor(named: "systemIndigo")!.setFill()
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
    
  static func < (lhs: Opponent, rhs: Opponent) -> Bool
  {
    if lhs.lastLoss == nil, rhs.lastLoss == nil { return false }
    if lhs.lastLoss == nil { return true }
    if rhs.lastLoss == nil { return false }
    return lhs.lastLoss! < rhs.lastLoss!
  }
  
  static func == (lhs: Opponent, rhs: Opponent) -> Bool
  {
    if lhs.lastLoss == nil, rhs.lastLoss == nil { return true }
    if lhs.lastLoss == nil { return false }
    if rhs.lastLoss == nil { return false }
    return lhs.lastLoss! == rhs.lastLoss!
  }
}

class DebugOpponent : Opponent  // @@@ REMOVE
{
  static var nextID : Int = 1
  
  let lossFrequency : Double
  
  init(_ name:String, gameAge:Double /*days*/, lossFrequency:TimeInterval, lastLoss:TimeInterval? = nil)
  {
    self.lossFrequency = lossFrequency
    
    DebugOpponent.nextID = DebugOpponent.nextID + 1
    
    let now = GameTime()
    
    var t : GameTime?
    if lastLoss != nil { t = now.offset(by: -1.0 * lastLoss!) }
    
    super.init(
      key : "DebugOpponent-\(DebugOpponent.nextID)",
      name : name,
      matchStart : now.offset(by: -86400.0 * gameAge),
      lastLoss : t
    )
  }
}
