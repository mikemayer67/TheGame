//
//  Opponent.swift
//  TheGame
//
//  Created by Mike Mayer on 2/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation
import UIKit

class Opponent : Comparable
{
  let playerID  : String
  let name      : String
  let image     : UIImage
  let gameStart : GameTime
  var lastLoss  : GameTime?
  
  var lastLossString : String
  {
    return lastLoss?.gameString ?? "No loss yet"
  }
  
  func lost(after time:GameTime?) -> Bool
  {
    if lastLoss == nil { return false }
    if time == nil     { return true  }
    return lastLoss! > time!

  }
  
  init(playerID:String, name:String, gameStart:GameTime)
  {
    self.playerID = playerID
    self.name = name
    self.gameStart = gameStart
    
    let renderer = UIGraphicsImageRenderer(size:CGSize(width:32,height:32));
    image = renderer.image {
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
    
    let pid = name
    DebugOpponent.nextID = DebugOpponent.nextID + 1
    
    let now = GameTime()
    
    let gameStart = now.offset(by: -86400.0 * gameAge)
    
    super.init(playerID:pid, name:pid, gameStart:gameStart)
    
    if let t = lastLoss {
      self.lastLoss = now.offset(by: -1.0 * t)
    }
  }

}
