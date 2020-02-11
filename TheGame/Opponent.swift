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
  let gameStart : TimeInterval
  var lastLoss  : TimeInterval?
  
  var lastLossString : String
  {
    if let t = lastLoss {
      return GameClock.localtime(gametime: t).lossTimeString
    } else {
      return "Hasn't lost yet"
    }
  }
  
  func lost(after time:TimeInterval?) -> Bool
  {
    return ( lastLoss ?? 0.0 ) > ( time ?? 0.0 )
  }
  
  init(playerID:String, name:String, gameStart:TimeInterval)
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
  
  static func < (lhs: Opponent, rhs: Opponent) -> Bool {
    return (lhs.lastLoss ?? 0.0) < (rhs.lastLoss ?? 0.0)
  }
  
  static func == (lhs: Opponent, rhs: Opponent) -> Bool {
    return (lhs.lastLoss ?? 0.0) == (rhs.lastLoss ?? 0.0)
  }
}

class DebugOpponent : Opponent  // @@@ REMOVE
{
  static var nextID : Int = 1
  
  let lossFrequency : Double
  
  init(_ name:String, gameAge:Int /*days*/, lossFrequency:TimeInterval, lastLoss:TimeInterval? = nil)
  {
    self.lossFrequency = lossFrequency
    
    let pid = name
    DebugOpponent.nextID = DebugOpponent.nextID + 1
    
    let now : TimeInterval = GameClock.gametime(localtime: Date())
    let gameStart = now - 86400.0 * Double(gameAge)
    
    super.init(playerID:pid, name:pid, gameStart:gameStart)
    
    if lastLoss != nil { self.lastLoss = now - lastLoss! }
  }
  
  
}
