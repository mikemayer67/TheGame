//
//  GamePlayer.swift
//  TheGame
//
//  Created by Mike Mayer on 2/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FacebookLogin

struct FacebookInfo
{
  let id      : String
  let name    : String
  let picture : String?
}

class GamePlayer
{
  let key               : String
  private(set) var name : String
  private(set) var icon : UIImage?      = nil
  private(set) var fb   : FacebookInfo? = nil
               
  var gameData : HashData? = nil
  
  init(key:String, name:String, gameData:HashData? = nil)
  {
    self.key        = key
    self.name       = name
    self.gameData   = gameData
  }
  
  init(key:String, facebook:FacebookInfo, gameData:HashData? = nil)
  {
    self.key        = key
    self.name       = facebook.name
    self.fb         = facebook
    self.gameData   = gameData
    self.icon       = createIcon(for:name)
    
    debug("Add logic to load FB image")
  }
  
  func createIcon(for name:String) -> UIImage
  {
    let renderer = UIGraphicsImageRenderer(size:CGSize(width:32,height:32));
    let image = renderer.image {
      c in
      
      let bg = UIColor(named:"playerIconBackgroud") ?? UIColor.black
      let fg = UIColor(named:"playerIconForeground") ?? UIColor.white
      
      let box = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
      let attr : Dictionary<NSAttributedString.Key,Any> = [
        .foregroundColor: fg ,
        .font: UIFont.systemFont(ofSize: 20.0, weight: .black)
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
}
