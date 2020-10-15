//
//  AppDelegate.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds
import UserNotifications

import FacebookCore

extension Notification.Name
{
  static let newDeviceToken = Notification.Name("newDeviceToken")
  static let remoteNotification = Notification.Name("remoteNotification")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool
  {
    // @@@ REMOVE AFTER TESTING
    if Bundle.main.object(forInfoDictionaryKey: "DevFreshStart") as? Bool ?? false
    {
      Defaults.clear()
    }
    else if Bundle.main.object(forInfoDictionaryKey: "DevUser") as? Bool ?? false
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
    
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) { (_,_) in }
    
    UNUserNotificationCenter.current().delegate = self
    
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
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
  {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    NotificationCenter.default.post(name: .newDeviceToken, object: nil, userInfo: ["token":token] )
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
  {
    NotificationCenter.default.post(name: .newDeviceToken, object: nil)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    NotificationCenter.default.post(
      name:.remoteNotification,
      object:nil,
      userInfo: ["content":notification.request.content] )
    
    completionHandler([.badge,.sound])
  }
  
  static var shared : AppDelegate
  {
    UIApplication.shared.delegate as! AppDelegate
  }
}
