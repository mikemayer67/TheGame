//
//  SplashViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GameKit

enum ViewEncodingError : Error
{
  case failedToDecode
}

class SplashViewController: UIViewController
{
  @IBOutlet weak var connectionLabel : UILabel!
  @IBOutlet weak var settingsButton : UIButton!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    GameCenterIF.shared.viewController = self
    GameCenterIF.shared.delgate = self
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
//    update(animated:animated)
  }
  
  func transitionToGame(animate:Bool)
  {
    guard let w = view.window else { fatalError("Attempting to transition from unwindowed view") }
    
    let gameStoryBoard = UIStoryboard(name: "LoserBoard", bundle: nil)
    let gameViewController = gameStoryBoard.instantiateInitialViewController()
   
    w.rootViewController = gameViewController
    if animate
    {
      UIView.transition(with: w, duration: 0.5, options: .transitionCurlUp, animations: {})
    }
  }
  
  func update(animated:Bool) -> Void
  {
    if GKLocalPlayer.local.isAuthenticated
    {
      connectionLabel.isHidden = true
      settingsButton.isHidden = true
    }
    else
    {
      connectionLabel.isHidden = false
      settingsButton.isHidden = false
    }
  }
  
  @IBAction func gotoSettings(_ sender : UIButton) -> Void
  {
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString)
    {
      UIApplication.shared.open(settingsUrl)
    }
  }
}

extension SplashViewController : GameCenterIFDelegate
{
  func localPlayer(authenticated: Bool)
  {
    update(animated: true)
    
    if authenticated
    {
      transitionToGame(animate: true)
    }
  }
}
