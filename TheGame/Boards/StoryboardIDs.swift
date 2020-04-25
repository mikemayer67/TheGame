//
//  StoryboardIDs.swift
//  TheGame
//
//  Created by Mike Mayer on 4/22/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

enum StoryBoardID : String
{
  case Main = "Main"
}

enum SegueID : String
{
  case CreateAccount          = "createAccount"
  case AccountLogin           = "accountLogin"
}

enum ViewControllerID : String
{
  case Root           = "rootVC"
  case SplashScreen   = "splashVC"
  case GameScreen     = "gameVC"
  case ConnectScreen  = "loginVC"
  case CreateAccount  = "createAccountVC"
  case AccountLogin   = "accountLoginVC"
}
