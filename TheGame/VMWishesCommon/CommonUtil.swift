//
//  CommonUtil.swift
//  TheGame
//
//  Created by Mike Mayer on 2/7/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension Array
{
  public subscript(safe index: Index) -> Iterator.Element? {
    guard index >= 0         else { return nil }
    guard index < self.count else { return nil }
    return self[index]
  }
}

extension Date
{
  var unixtime: Double { return self.timeIntervalSince1970  }
  
  static func -(lhs:Date,rhs:Date) -> TimeInterval
  { return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970 }
}

typealias HashData = Dictionary<String,Any>

extension HashData
{
  func getInt    (_ key:String) -> Int?    { return self[key] as? Int    }
  func getDouble (_ key:String) -> Double? { return self[key] as? Double }
  func getBool   (_ key:String) -> Bool?   { return self[key] as? Bool   }
  func getString (_ key:String) -> String? { return self[key] as? String }
  
  mutating func set(value:Any?, for key:String)
  {
    if let v = value { self[key] = v }
    else { self.removeValue(forKey: key) }
  }
}

extension UIViewController
{
  func infoPopup(title:String, message:[String], ok:String? = nil,
                 animated:Bool = true, completion:(()->Void)? = nil)
  {
    infoPopup(title: title,
              message: message.joined(separator: "\n\n"),
              ok: ok,
              animated: animated,
              completion:completion)
  }
  
  func infoPopup(title:String, message:String, ok:String? = nil,
                 animated:Bool = true, completion:(()->Void)? = nil)
  {
    let ok = ok ?? "OK"
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in completion?() } ) )
    self.present(alert,animated:animated)
  }
  
  func confirmationPopup(title:String, message:[String], ok:String? = nil, cancel:String? = nil,
                         animated:Bool = true, completion:((Bool)->Void)? = nil)
  {
    confirmationPopup(title: title,
                      message: message.joined(separator: "\n\n"),
                      ok:ok,
                      cancel:cancel,
                      animated:animated,
                      completion:completion)
  }
  
  func confirmationPopup(title:String, message:String, ok:String? = nil, cancel:String? = nil,
                         animated:Bool = true, completion:((Bool)->Void)? = nil)
  {
    let ok = ok ?? "OK"
    let cancel = cancel ?? "Cancel"
    
    let alert = UIAlertController(title:title, message: message, preferredStyle:.alert)
    alert.addAction(UIAlertAction(title: cancel, style: .cancel,  handler: { _ in completion?(false) } ) )
    alert.addAction(UIAlertAction(title: ok,     style: .default, handler: { _ in completion?(true)  } ) )
    self.present(alert,animated: true)
  }
}

class DelayedCallback
{
  typealias Callback = (_ sender:Any)->()
    
  private(set) var updateTimer : Timer?
  private(set) var delay       : TimeInterval
  private(set) var callback    : Callback
  
  init(delay : TimeInterval = 0.3, callback : @escaping Callback)
  {
    self.callback = callback
    self.delay    = delay
  }
  
  func start(_ sender:Any? = nil)
  {
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false)
    { (_) in self.callback(sender ?? self)  }
  }
}

func debug(_ args:Any...)
{
  print("DEBUG::",args)
}


