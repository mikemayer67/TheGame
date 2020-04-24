//
//  VCExtensions.swift
//  TheGame
//
//  Blatently copied from http://brainwashinc.com/2017/07/21/loading-activity-indicator-ios-swift/
//

import UIKit

fileprivate var vSpinner : UIView?

extension UIViewController
{
//  func showSpinner(onView : UIView)
//  {
//    if vSpinner != nil { removeSpinner() }
//
//    let spinnerView = UIView.init(frame: onView.bounds)
//    spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
//    let ai = UIActivityIndicatorView.init(style: .large)
//    ai.startAnimating()
//    ai.center = spinnerView.center
//
//    DispatchQueue.main.async {
//      spinnerView.addSubview(ai)
//      onView.addSubview(spinnerView)
//    }
//
//    vSpinner = spinnerView
//  }
//
//  func removeSpinner()
//  {
//    DispatchQueue.main.async {
//      vSpinner?.removeFromSuperview()
//      vSpinner = nil
//    }
//  }
  
  func performSegue(_ target:SegueID, sender:Any?)
  {
    performSegue(withIdentifier: target.rawValue, sender: sender)
  }
}
