//
//  StoryboardIDs.swift
//  TheGame
//
//  Created by Mike Mayer on 4/22/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum ViewControllerID : String
{
  case none           = ""
  case Root           = "rootVC"
  case SplashScreen   = "splashVC"
  case GameScreen     = "gameVC"
  case ConnectScreen  = "loginVC"
}

enum SegueID : String
{
  case Settings = "showSettings"
}

extension UIViewController
{
  func instantiate(_ id:ViewControllerID) -> UIViewController
  {
    guard let vc = self.storyboard?.instantiateViewController(identifier: id.rawValue)
      else { fatalError("Storyboard is missing: \(id.rawValue)") }
    return vc
  }
}

extension RootViewController
{
  func update()
  {
    let id : ViewControllerID =
    ( TheGame.server.connected == false ? .SplashScreen
      : TheGame.shared.me      == nil   ? .ConnectScreen
      : .GameScreen )
        
    self.present(viewControllerID: id.rawValue)
  }
}
