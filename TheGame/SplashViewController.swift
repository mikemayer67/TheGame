//
//  SplashViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum ViewEncodingError : Error
{
  case failedToDecode
}

class SplashViewController: UIViewController
{
  @IBOutlet weak var connectionLabel : UILabel!
  @IBOutlet weak var connectButton : UIButton!
  @IBOutlet weak var playAloneButton : UIButton!
  
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
    // @@@ TODO Check login status
  }
  
  @IBAction func gotoSettings(_ sender : UIButton) -> Void
  {
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString)
    {
      UIApplication.shared.open(settingsUrl)
    }
  }
}
