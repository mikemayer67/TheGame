//
//  ViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController
{  
  @IBOutlet weak var oppenentTable: UITableView!
  @IBOutlet weak var buttonView: UIImageView!
  @IBOutlet weak var lostButton: UIButton!
  @IBOutlet weak var bannerView: GADBannerView!
  @IBOutlet weak var lastLossLabel: UILabel!
  
  @IBOutlet weak var game: GameModel!
    
  private var buttonImages = [UIImage]()
  
  private let feedback = UISelectionFeedbackGenerator()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    for i in 1...12 {
      if let image = UIImage(named:String(format:"button_%02d",i)) {
        buttonImages.append(image)
      }
    }
    guard buttonImages.isEmpty == false else { fatalError("missing button images") }
    
    //@@@ REMOVE
    game.add(DebugOpponent("Tom Smith",gameAge:  5, lossFrequency: 3600.0))
    game.add(DebugOpponent("Gus LeChat",gameAge:  3, lossFrequency: 1800.0, lastLoss: 600.0))
    game.add(DebugOpponent("Miss Marple",gameAge: 10, lossFrequency: 5400.0, lastLoss:  10.0))
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    initilizeBannerAd()
    
    update()
  }
  
  @IBAction func addOpponent(_ sender: UIButton)
  {
    print("add opponent")
  }
  
  @IBAction func handleLostButton(_ sender: UIButton)
  {
    feedback.selectionChanged()
    
    // disable the actual lost button (sits on top of the animated button)
    lostButton.isEnabled = false
    UIView.animate(withDuration: 0.2, animations: {
      self.lostButton.alpha = 0
    }, completion: {
      isComplete in
      self.lostButton.isHidden = true
      self.lostButton.alpha = 1
    } )
    // animate the button press
    lostButton.isHidden = true
    buttonView.image = buttonImages.last! // don't revert to initial button image
    buttonView.animationImages = buttonImages
    buttonView.animationDuration = 0.2
    buttonView.animationRepeatCount = 1
    buttonView.startAnimating()
    // fade to disabled button image (below animated button)
    UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
      self.buttonView.alpha = 0
    }, completion: {
      isComplete in
      self.buttonView.alpha = 1
      self.buttonView.isHidden = true
    } )
    
    game.iLostTheGame()
  }
  
  func update() -> Void
  {
    if let lastLoss = game.lastLoss
    {
      lastLossLabel.text = GameClock.localtime(gametime: lastLoss).lossTimeString
    }
    else
    {
      lastLossLabel.text = "Go ahead, push the button..."
    }
    
    oppenentTable.reloadData()
    
    if game.allowedToLose
    {
      if !lostButton.isEnabled {
        buttonView.image = buttonImages.first!
        buttonView.alpha = 0.0
        buttonView.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
          self.buttonView.alpha = 1.0
        }, completion: {
          isComplete in
          self.buttonView.alpha = 1.0
          self.lostButton.isHidden = false
          self.lostButton.isEnabled = true
        })
      }
    }
    else
    {
      lostButton.isHidden = true
      lostButton.isEnabled = false
      buttonView.isHidden = true
    }
  }
}
