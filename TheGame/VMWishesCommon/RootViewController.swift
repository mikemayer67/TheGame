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

/**
 Simple subclass of UIViewController that adds a single attribute *rootViewController*.
 
 The intent is to subclass this view controller to add specific functionality.
 */
class ChildViewController : UIViewController
{
  var rootViewController : RootViewController!
}

/**
 Sends the FailedToConnectToServer notification on the default notification center
 */
func failedToConnectToServer()
{
  NotificationCenter.default.post(name: .failedToConnectToServer, object: nil, userInfo: nil)
}

/**
 A container view for handling the presentation of *ChildViewController* instances.
 
 Both the root view controller and the presented child view controllers must be
 defined in a storyboard.  More specifically, they must be defined in the same
 storyboard.  The root view controller identifies the child view through use of the
 storyboard ID field.
 */
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
    
    /**
     Configures *RootViewController* instance to observe FailedToConnectToServer
     notifcations.  In response to this notification, it invokes the update method,
     which must be defined in an extesion to this class.
     */
    NotificationCenter.default.addObserver(
      forName: .failedToConnectToServer,
      object: nil,
      queue: OperationQueue.main
    ) { (notification) in
      if let loginVC = self.currentVC as? LoginViewController { loginVC.cancel() }
      self.update()
    }
  }
  
  /**
   Retrieves the the *ChildViewController* from the storyboard with the specified ID
   
   - Parameter viewControllerID: storyboard ID of the controller to be presented
   */
  
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
  
  /**
   Replaces the current presented view controller with the child controller
   (a *ChildViewController* instance) identifed by the specified controller string.
   
   If the specified ID happens to be the ID of the currently presented controller,
   this method returns immediately without further action.  Otherwise, the *childView*
   method is used to retrieve the desired view controller from the storyboard.
   
   - Parameter viewControllerID: storyboard ID of the controller to be presented
   */
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
  
}
