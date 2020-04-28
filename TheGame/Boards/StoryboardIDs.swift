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
  
  func update()
  {
    let id : ViewControllerID =
    ( TheGame.server.connected == false ? .SplashScreen
      : TheGame.shared.me      == nil   ? .ConnectScreen
      : .GameScreen )
    
    self.transition(to: id)
  }
  
  @IBAction func returnToRoot(segue:UIStoryboardSegue)
  {
    debug("segue to Root")
    self.update()
  }
}

extension ChildViewController
{
  func updateRootView()
  {
    rootViewController.update()
  }
}
