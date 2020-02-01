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
  var timer : Timer?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    let launchStoryBoard = UIStoryboard(name: "LaunchScreen", bundle: nil)
    let launchViewController = launchStoryBoard.instantiateInitialViewController()
    
    guard let launchView = launchViewController?.view else
    {
      fatalError("launch storyboard is missing a view")
    }
 
    do
    {
      let data =
        try NSKeyedArchiver.archivedData( withRootObject: launchView, requiringSecureCoding: false )
      
      let decodedData =
        try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
      
      guard let splashView = decodedData as? UIView else { throw ViewEncodingError.failedToDecode }
      
      view = splashView
            
      timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false)
      {  _ in
        print("timer up, transition")
        self.transitionToGame(animate: true)
      }
    }
    catch
    {
      print("catch bloc, transition")
      transitionToGame(animate: false)
    }
  }
  
  func transitionToGame(animate:Bool)
  {
    let vv = view
    let ww = vv?.window
    guard let w = view.window else { fatalError("Attempting to transition from unwindowed view") }
    
    let gameStoryBoard = UIStoryboard(name: "Game", bundle: nil)
    let gameViewController = gameStoryBoard.instantiateInitialViewController()
   
    w.rootViewController = gameViewController
    if animate
    {
      UIView.transition(with: w, duration: 0.5, options: .transitionCurlUp, animations: {})
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    timer?.invalidate()
    transitionToGame(animate: true)
  }
}
