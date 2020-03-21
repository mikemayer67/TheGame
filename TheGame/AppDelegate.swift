//
//  AppDelegate.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds
import GameKit

import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
  {
    // Override point for customization after application launch.
    
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String)];
    
    if GameServer.shared.hasConnection()
    {
      let storyBoard = UIStoryboard(name: "Main", bundle: nil)
      let gameVC = storyBoard.instantiateViewController(withIdentifier: "loserBoard")
      self.window?.rootViewController = gameVC
    }
    
    print("NSHomeDirectory:",NSHomeDirectory())
    return true
  }
}

