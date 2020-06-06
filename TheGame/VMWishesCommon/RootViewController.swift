//
//  RootViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 4/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension Notification.Name
{
  static let failedToConnectToServer = Notification.Name("failedToConnectToServer")
}

class ChildViewController : UIViewController
{
  var rootViewController : RootViewController!
}

func failedToConnectToServer()
{
  NotificationCenter.default.post(name: .failedToConnectToServer, object: nil, userInfo: nil)
}

@IBDesignable
class RootViewController: UIViewController
{
  @IBInspectable var initialVC : String!
  
  var currentVC  : ChildViewController?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let vc = childView(withName: initialVC)
    
    currentVC = vc
    
    addChild(vc)
    vc.view.frame = view.bounds
    view.addSubview(vc.view)
    vc.didMove(toParent: self)
  }
  
  private func childView(withName viewControllerID:String) -> ChildViewController
  {
    guard let sb = storyboard
      else { fatalError("RootViewController must originate in a storyboard") }
    
    guard let vc =
      sb.instantiateViewController(identifier: viewControllerID) as? ChildViewController
      else { fatalError("Cannot find ChildViewController: \(viewControllerID)") }
    
    vc.rootViewController = self
    
    return vc
  }
  
  func present(viewControllerID:String)
  {
    guard currentVC != nil    else { return }
    
    let vc = childView(withName: viewControllerID)
    
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
  
  func setupFailureNotification()
  {
    NotificationCenter.default.addObserver(
      forName: .failedToConnectToServer,
      object: nil,
      queue: OperationQueue.main
    ) { (notification) in
      debug("Connection failure notification: \(notification)")
      self.update()
    }
  }
}
