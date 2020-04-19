//
//  RootViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/23/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum old_RootViewControllerID : String
{
  case startup            = "startup"
  case loginNavController = "loginNavController"
  case loserBoard         = "loserBoard"
}

class old_RootViewController
{
  static let shared = RootViewController()
  
  var rootWindow : UIWindow? = nil
  
  func update(animate : Bool = true)
  {
    if let w = rootWindow
    {
      let storyBoard = UIStoryboard(name: "Main", bundle: nil)

      let id : RootViewControllerID = TheGame.server.connected ?
        ( TheGame.server.hasLogin ? .loserBoard : .loginNavController ) :
        .startup
      
      let vc = storyBoard.instantiateViewController(withIdentifier: id.rawValue)
      let ovc = w.rootViewController
      
      if vc != ovc
      {
        w.rootViewController = vc

        if animate, ovc != nil,
          let snapshot = ovc!.view.snapshotView(afterScreenUpdates:true)
        {
          vc.view.addSubview(snapshot)

          UIView.animate(withDuration: 0.3, animations: { () in
            snapshot.layer.opacity = 0
            snapshot.layer.transform = CATransform3DMakeScale(0,1.5,1)
          }, completion: {
            (value:Bool) in snapshot.removeFromSuperview()
          } )

        }
      }
    }
  }
}
