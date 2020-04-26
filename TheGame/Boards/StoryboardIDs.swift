//
//  StoryboardIDs.swift
//  TheGame
//
//  Created by Mike Mayer on 4/22/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

enum ViewControllerID : String
{
  case Root           = "rootVC"
  case SplashScreen   = "splashVC"
  case GameScreen     = "gameVC"
  case ConnectScreen  = "loginVC"
  case CreateAccount  = "createAccountVC"
  case AccountLogin   = "accountLoginVC"
}

extension RootViewController
{
  func transition(to vcid:ViewControllerID)
  {
    present(viewControllerID: vcid.rawValue)
  }
}

extension ChildViewController
{
  func updateRootView()
  {
    let id : ViewControllerID =
    ( TheGame.server.connected == false ? .SplashScreen
      : TheGame.shared.me      == nil   ? .ConnectScreen
      : .GameScreen )
    
    rootViewController.transition(to: id)
  }
}
