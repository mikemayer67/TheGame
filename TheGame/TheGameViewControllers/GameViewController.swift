//
//  GameViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds


class GameViewController: ChildViewController
{  
  @IBOutlet weak var oppenentTable: UITableView!
  @IBOutlet weak var buttonView: UIImageView!
  @IBOutlet weak var lostButton: UIButton!
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var lastLossLabel: UILabel!
  
  @IBOutlet weak var meIcon: UIImageView!
  
  @IBOutlet weak var game: GameModel!  // @@@ REMOVE
    
  private var buttonIsEnabled = true
  
  private let feedback = UISelectionFeedbackGenerator()
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
        
    for opponent in TheGame.shared.opponents
    {
      game.add(opponent)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    TheGame.shared.errorDelegate  = self
    TheGame.shared.updateDelegate = self
    
    meIcon.layer.masksToBounds = true
    meIcon.layer.cornerRadius = 12
        
    initilizeBannerAd()
    
    update(animated:false)
    game.viewController = self
    
    if let icon = TheGame.shared.me?.icon
    {
      meIcon.image = icon
    }
  }
  
  @IBAction func addOpponent(_ sender: UIButton)
  {
    track("@@@ add opponent")
  }
  
  @IBAction func handleLostButton(_ sender: UIButton)
  {
    feedback.selectionChanged()
    hideLostButton(animated: true)
    game.iLostTheGame()
  }
  
  func update(animated:Bool = true) -> Void
  {
    var text = "Go ahead, push the button..."
    if let t = game.lastLoss?.string { text = t }
    lastLossLabel.text = text
      
    oppenentTable.reloadData()
    
    if game.allowedToLose { showLostButton(animated:animated) }
    else                  { hideLostButton(animated:animated) }
  }
  
}

private extension GameViewController
{
  func showLostButton(animated:Bool)
  {
    guard !buttonIsEnabled else { return }
    buttonIsEnabled = true

    let buttonImage = UIImage(named:"button_01")
    
    if animated
    {
      buttonView.image    = buttonImage
      buttonView.alpha    = 0.0
      lostButton.alpha    = 0.0
      buttonView.isHidden = false
      lostButton.isHidden = false
      UIView.animate(withDuration: 0.25, animations: {
        self.buttonView.alpha = 1.0
        self.lostButton.alpha = 1.0
      }, completion: { _ in
        self.buttonView.alpha = 1.0
        self.lostButton.alpha = 1.0
        self.lostButton.isEnabled = true
      })
    }
    else
    {
      buttonView.alpha = 1.0
      buttonView.image = buttonImage
      buttonView.isHidden = false
      
      lostButton.isHidden = false
      lostButton.isEnabled = true
    }
  }
  
  func hideLostButton(animated:Bool)
  {
    guard buttonIsEnabled else { return }
    buttonIsEnabled = false
    
    if animated
    {
      // disable the actual lost button
      lostButton.isEnabled = false
      UIView.animate(withDuration: 0.2, animations: {
        self.lostButton.alpha = 0.0
      }, completion: { _ in
        self.lostButton.isHidden = true
      } )
      
      // animate the button press
      
      var buttonImages = [UIImage]()
      for i in 1...12 {
         if let image = UIImage(named:String(format:"button_%02d",i)) {
           buttonImages.append(image)
         }
       }

      buttonView.image = buttonImages.last! // don't revert to initial button image
      buttonView.animationImages = buttonImages
      buttonView.animationDuration = 0.5
      buttonView.animationRepeatCount = 1
      buttonView.startAnimating()
      UIView.animate(withDuration: 0.5, delay: 0.6, animations: {
        self.buttonView.alpha = 0.0
      }, completion: {
        isComplete in
        self.buttonView.isHidden = true
      } )
    }
    else
    {
      buttonView.isHidden = true
      lostButton.isHidden = true
      lostButton.isEnabled = false
    }
  }
}

extension GameViewController : TheGameErrorHandler, TheGameUpdateDelegate
{
  func failedConnection(_ theGame: TheGame)
  {
    rootViewController.update()
  }
  
  func internalError(_ theGame: TheGame, error: String, file: String, function: String)
  {
    internalError(error, file:file, function:function)
  }
  
  func opponentsUpdated(_ theGame: TheGame)
  {
    track("TheGame updated opponent list")
  }
}


extension GameViewController : GADBannerViewDelegate
{
  func initilizeBannerAd()
  {
    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    bannerView.rootViewController = self
    bannerView.delegate = self
    
    bannerView.load(GADRequest())
  }
  
  /// Tells the delegate an ad request loaded an ad.
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    track("adViewDidReceiveAd")
  }

  /// Tells the delegate an ad request failed.
  func adView(_ bannerView: GADBannerView,
      didFailToReceiveAdWithError error: GADRequestError) {
    track("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }

  /// Tells the delegate that a full-screen view will be presented in response
  /// to the user clicking on an ad.
  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    track("adViewWillPresentScreen")
  }

  /// Tells the delegate that the full-screen view will be dismissed.
  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    track("adViewWillDismissScreen")
  }

  /// Tells the delegate that the full-screen view has been dismissed.
  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    track("adViewDidDismissScreen")
  }

  /// Tells the delegate that a user click will open another app (such as
  /// the App Store), backgrounding the current app.
  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    track("adViewWillLeaveApplication")
  }
}
