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

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool
  {
    // @@@ REMOVE AFTER TESTING
    if Bundle.main.object(forInfoDictionaryKey: "DevUser") as? Bool ?? false
    {
      Defaults.username = "mikemayer67"
      Defaults.alias   = "Mikey M"
      Defaults.removeObject(forKey: "lastErrorEmail")
      Defaults.userkey = nil
    }
        
    // Facebook
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
    // AdMobi
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String)];
    
    if let rvc = window?.rootViewController as? RootViewController
    {
      rvc.setupFailureNotification()
    }
    
    track("NSHomeDirectory:",NSHomeDirectory())
    
    return true
  }
        
  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool
  {
    // Facebook
    return ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
  }
  
  static var shared : AppDelegate
  {
    UIApplication.shared.delegate as! AppDelegate
  }
}

