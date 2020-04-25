//
//  RootViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 4/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class RootViewController: UIViewController
{
  var currentVC : UIViewController?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let sb = UIStoryboard(.Main)
    let vc = sb.instantiateViewController(.SplashScreen)
    
    currentVC = vc
    
    addChild(vc)
    vc.view.frame = view.bounds
    view.addSubview(vc.view)
    vc.didMove(toParent: self)
  }
  
  func update()
  {
    guard currentVC != nil else { return }
    
    let id : ViewControllerID =
      ( TheGame.server.connected == false ? .SplashScreen
        : TheGame.shared.me      == nil   ? .ConnectScreen
        : .GameScreen  )
    
    let sb = UIStoryboard(.Main)
    let vc = sb.instantiateViewController(id)
    
    guard vc != currentVC else { return }
        
    currentVC?.willMove(toParent: nil)
    addChild(vc)
    
    transition(from: currentVC!, to: vc, duration: 0.3,
               options: [.transitionCrossDissolve,.curveEaseInOut],
               animations: { vc.view.frame = self.view.bounds } )
    {
      (_) in
      self.currentVC!.removeFromParent()
      vc.didMove(toParent: self)
      self.currentVC = vc
    }
    
  }
}
