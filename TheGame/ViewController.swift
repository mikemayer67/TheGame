//
//  ViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, GADBannerViewDelegate {
  
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var buttonView: UIImageView!
  @IBOutlet weak var lostButton: UIButton!
  
  private var buttonImages = [UIImage]()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    for i in 1...12 {
      if let image = UIImage(named:String(format:"button_%02d",i)) {
        buttonImages.append(image)
      }
    }
    guard buttonImages.isEmpty == false else { fatalError("missing button images") }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    bannerView.rootViewController = self
    bannerView.delegate = self
    
    bannerView.load(GADRequest())
  }
  
  @IBAction func handleLostButton(_ sender: UIButton)
  {
    lostButton.isEnabled = false
    UIView.animate(withDuration: 0.2, animations: {
      self.lostButton.alpha = 0
    }, completion: {
      isComplete in
      self.lostButton.isHidden = true
      self.lostButton.alpha = 1
    } )
    lostButton.isHidden = true
    buttonView.image = buttonImages.last!
    buttonView.animationImages = buttonImages
    buttonView.animationDuration = 0.2
    buttonView.animationRepeatCount = 1
    buttonView.startAnimating()
    
    UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
      self.buttonView.alpha = 0
    }, completion: {
      isComplete in
      self.buttonView.alpha = 1
      self.buttonView.isHidden = true
    } )
  }
  /// Tells the delegate an ad request loaded an ad.
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("adViewDidReceiveAd")
  }

  /// Tells the delegate an ad request failed.
  func adView(_ bannerView: GADBannerView,
      didFailToReceiveAdWithError error: GADRequestError) {
    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }

  /// Tells the delegate that a full-screen view will be presented in response
  /// to the user clicking on an ad.
  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("adViewWillPresentScreen")
  }

  /// Tells the delegate that the full-screen view will be dismissed.
  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("adViewWillDismissScreen")
  }

  /// Tells the delegate that the full-screen view has been dismissed.
  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("adViewDidDismissScreen")
  }

  /// Tells the delegate that a user click will open another app (such as
  /// the App Store), backgrounding the current app.
  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    print("adViewWillLeaveApplication")
  }

}

