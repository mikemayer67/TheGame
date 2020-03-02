//
//  GameViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GameViewController: UIViewController
{  
  @IBOutlet weak var oppenentTable: UITableView!
  @IBOutlet weak var buttonView: UIImageView!
  @IBOutlet weak var lostButton: UIButton!
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var lastLossLabel: UILabel!
  
  @IBOutlet weak var game: GameModel!
    
  private var buttonIsEnabled = true
  
  private let feedback = UISelectionFeedbackGenerator()
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    //@@@ REMOVE
    game.add(DebugOpponent("Tom Smith",gameAge:  5, lossFrequency: 3600.0))
    game.add(DebugOpponent("Gus LeChat",gameAge:  3, lossFrequency: 1800.0, lastLoss: 600.0))
    game.add(DebugOpponent("Miss Marple",gameAge: 10, lossFrequency: 5400.0, lastLoss:  10.0))
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    initilizeBannerAd()
    GameCenterIF.shared.viewController = self
    GameCenterIF.shared.delgate = self
    
    update(animated:false)
    game.viewController = self
  }
  
  @IBAction func addOpponent(_ sender: UIButton)
  {
    print("add opponent")
  }
  
  @IBAction func handleLostButton(_ sender: UIButton)
  {
    feedback.selectionChanged()
    hideLostButton(animated: true)
    game.iLostTheGame()
  }
  
  func update(animated:Bool = true) -> Void
  {
    lastLossLabel.text = game.lastLoss?.gameString ?? "Go ahead, push the button..."
    oppenentTable.reloadData()
    
    if game.allowedToLose { showLostButton(animated:animated) }
    else                  { hideLostButton(animated:animated) }
  }
  
}

extension GameViewController : GameCenterIFDelegate
{
  func localPlayer(authenticated: Bool) {
    if authenticated {
      print("still authenticated, no action needed")
    }
    else
    {
      guard let w = view.window else { fatalError("Attempting to transition from unwindowed view") }
       
       let splashBoard = UIStoryboard(name: "Main", bundle: nil)
       let vc = splashBoard.instantiateInitialViewController()
      
       w.rootViewController = vc
       UIView.transition(with: w, duration: 0.5, options: .transitionCrossDissolve, animations: {})
    }
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

      print("animate:",buttonImages.count)
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
