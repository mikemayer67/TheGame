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
    if let uk = Bundle.main.object(forInfoDictionaryKey: "UserkeyOverride") as? String
    {
      debug("UserKeyOverride: '\(uk)'")
      if uk.count > 0 { UserDefaults.standard.set(uk, forKey: "userkey") }
      else            { UserDefaults.standard.removeObject(forKey: "userkey") }
    }
    if let u = Bundle.main.object(forInfoDictionaryKey: "UsernameOverride") as? String
    {
      debug("UserNameOverride: '\(u)'")
      if u.count > 0 { UserDefaults.standard.set(u, forKey: "username") }
      else            { UserDefaults.standard.removeObject(forKey: "username") }
    }
    if let a = Bundle.main.object(forInfoDictionaryKey: "AliasOverride") as? String
    {
      debug("AliasOverride: '\(a)'")
      if a.count > 0 { UserDefaults.standard.set(a, forKey: "alias") }
      else            { UserDefaults.standard.removeObject(forKey: "alias") }
    }
    UserDefaults.standard.removeObject(forKey: "lastErrorEmail")
    
    // Facebook
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
    // AdMobi
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String)];
    
    debug("NSHomeDirectory:",NSHomeDirectory())
    
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

