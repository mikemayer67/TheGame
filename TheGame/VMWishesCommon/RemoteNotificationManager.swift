//
//  RemoteNotificationManager.swift
//  TheGame
//
//  Created by Mike Mayer on 10/21/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

protocol RemoteNotificationDelegate
{
  func handleDeviceChange(_:RemoteNotificationManager, device:String? )
  func handleStateChange(_:RemoteNotificationManager, active:Bool )
  func handleRemoteNotification(_:RemoteNotificationManager, content:UNNotificationContent )
}

class RemoteNotificationManager : NSObject, UNUserNotificationCenterDelegate
{
  static let shared = RemoteNotificationManager()
  
  var delegate : RemoteNotificationDelegate? = nil
  
  private(set) var enabled : Bool? = nil
  {
    didSet {
      debug("RNM: enabled now=\(enabled ?? false) was=\(oldValue ?? false)")
      if enabled != oldValue { delegate?.handleStateChange(self, active:active) }
    }
  }
  
  var device : String? = nil
  {
    didSet {
      debug("RNM: device now=\(device ?? "nil") was=\(oldValue ?? "nil")")
      if device != oldValue { delegate?.handleDeviceChange(self, device:device) }
    }
  }
  
  var active : Bool { (enabled ?? false) && device != nil }
  
  override init()
  {
    debug("RNM: init")
    super.init()
    
    NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main, using: { (notification) in self.updateState() }
    )
    
    UNUserNotificationCenter.current().delegate = self
  }
  
  func updateState()
  {
    debug("RNM:updateState()")
    UNUserNotificationCenter.current().getNotificationSettings()
    {
      settings in
      let granted = ( settings.authorizationStatus == UNAuthorizationStatus.authorized )
      
      let thread = Thread.current.isMainThread ? "main" : "other"
      debug("RNM:updateState granted=\(granted) thread=\(thread)")
      
      DispatchQueue.main.async {
        if granted { UIApplication.shared.registerForRemoteNotifications() }
       self.enabled = granted
      }
    }
  }
  
  func userNotificationCenter( _ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void )
  {
    let thread = Thread.current.isMainThread ? "main" : "other"
    debug("RNM:notification received  thread=\(thread)")
    delegate?.handleRemoteNotification(self, content: notification.request.content)
    completionHandler([.badge,.sound])
  }
  
}
