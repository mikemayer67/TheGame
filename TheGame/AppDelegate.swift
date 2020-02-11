//
//  AppDelegate.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
        
    GADMobileAds.sharedInstance().start(completionHandler: nil)
        
    return true
  }

    
//    if let w = window, let rvc = w.rootViewController
//    {
//      let svc = SplashViewController()
//      if svc
//      
//      w.rootViewController = svc
//
//      let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false)
//      { t in
//        print("timer fired... transition now")
//        w.rootViewController = rvc
//        
//        UIView.transition(with: w, duration: 0.3, options: .transitionCurlUp, animations: {})
//        {
//          v in
//          print("transition complete")
//        }
//      }
//    }

}

