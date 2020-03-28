//
//  RootViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/23/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class RootViewController
{
  static let shared = RootViewController()
  
  var rootWindow : UIWindow?
  {
    didSet { setViewController() }
  }
  
  func setViewController()
  {
    if let w = rootWindow
    {
      if GameServer.shared.hasConnection()
      {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let gameVC = storyBoard.instantiateViewController(withIdentifier: "loserBoard")
        w.rootViewController = gameVC
      }
      else
      {
        
      }
    }
  }
}
