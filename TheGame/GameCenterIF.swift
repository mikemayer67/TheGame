//
//  GameCenterIF.swift
//  TheGame
//
//  Created by Mike Mayer on 2/13/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation
import GameKit

protocol GameViewController : UIViewController
{
  func gameAuthenticationChanged(authenticated:Bool) -> Void
}

class GameCenterIF
{
  static let shared = GameCenterIF()
  
  static var isAuthenticated : Bool { GKLocalPlayer.local.isAuthenticated }
  
  var viewController : GameViewController?
  
  init()
  {
    GKLocalPlayer.local.authenticateHandler = { vc, error in
      print("authentication handler called")
      if GKLocalPlayer.local.isAuthenticated {
        print("already authenticated")
      }
      else if vc != nil {
        self.viewController?.present(vc!,animated: true)
      }
      else
      {
        NSLog("Error authentication to GameCenter: %@", error?.localizedDescription ?? "(unknown)")
      }
    }
  }
}
