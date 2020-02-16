//
//  GameCenterIF.swift
//  TheGame
//
//  Created by Mike Mayer on 2/13/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation
import GameKit

protocol GameCenterIFDelegate
{
  func localPlayer(authenticated:Bool) -> Void
}

class GameCenterIF
{
  static let shared = GameCenterIF()
  
  static var isAuthenticated : Bool { GKLocalPlayer.local.isAuthenticated }
    
  var viewController : UIViewController?
  var delgate        : GameCenterIFDelegate?
  
  init()
  {
    GKLocalPlayer.local.authenticateHandler = { vc, error in      
      if error == nil, vc == nil, GKLocalPlayer.local.isAuthenticated
      {
        self.delgate?.localPlayer(authenticated: GKLocalPlayer.local.isAuthenticated)
      }
      else if vc != nil
      {
        let alert = UIAlertController(title: "Game Center Connection Required", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Connect", style: .default, handler: { _ in
          self.viewController?.present(vc!,animated: true)
        }))
        alert.addAction(UIAlertAction(title:"Not now", style: .cancel, handler: { _ in
          self.delgate?.localPlayer(authenticated: false)
        }))
        self.viewController?.present(alert,animated: true)
      }
      else
      {
        self.delgate?.localPlayer(authenticated: false)
      }
    }
  }
}
