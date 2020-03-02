//
//  GameModel.swift
//  TheGame
//
//  Created by Mike Mayer on 2/6/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class GameModel : NSObject
{
  let unchallangedLossInterval = 15.0 // may lose every hour
  let challengedLossInterval   = 5.0   // may lose one minute after opponent loses
  
  weak var viewController : GameViewController?
  
  private(set) var opponents = [Opponent]()
  
  override func awakeFromNib()
  {
    print("awake from nib: GameModel")
    if let t = UserDefaults.standard.object(forKey: "LastLoss") as? TimeInterval
    {
      lastLoss = GameTime(networktime: t)
    }
  }
    
  private(set) var nextLossTimer : Timer?

  private(set) var lastLoss : GameTime?
  { didSet { updateNextAllowableLoss() } }
  
  private(set) var nextAllowableLoss : GameTime = GameTime()
  { didSet { updateLossTimer() } }

  var allowedToLose : Bool { GameTime() > nextAllowableLoss }
   
  func add(_ opponent:Opponent) -> Void
  {
    opponents.append(opponent)
  }
  
  func iLostTheGame() -> Void
  {
    lastLoss = GameTime()
    UserDefaults.standard.set(lastLoss?.networktime, forKey:"LastLoss")
    viewController?.update()
  }
}

extension GameModel // @@@ REMOVE
{
  @IBAction func RESET(_ sender: UIButton)  // @@@ REMOVE
  {
    UserDefaults.standard.removeObject(forKey: "LastLoss")
    lastLoss = nil
  }
  
  @IBAction func opponentLost(_ sender: UIButton)
  {
    print("opponent",sender.tag,"lost")
    opponents[sender.tag].lastLoss = GameTime()
    updateNextAllowableLoss()
    viewController?.update()
  }
}


private extension GameModel
{
  func updateNextAllowableLoss() -> Void
  {
    if lastLoss == nil
    {
      nextAllowableLoss = GameTime() // never loss before, can lose immediately
    }
    else
    {
      var nextLossDelay = unchallangedLossInterval
      for opponent in opponents {
        if opponent.lost(after: lastLoss) {
          nextLossDelay = challengedLossInterval
          break
        }
      }
      nextAllowableLoss = lastLoss!.offset(by: nextLossDelay)
    }
  }
  
  func updateLossTimer() -> Void
  {
    if let t = nextLossTimer {
      t.invalidate()
      nextLossTimer = nil
    }
    
    if let vc = viewController
    {
      let delay = nextAllowableLoss - GameTime()
      
      if delay > 0.0 {
        nextLossTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false)
        { _ in
          vc.update()
          self.nextLossTimer = nil
        }
      }
      else
      {
        vc.update()
      }
    }
  }
}

//extension GameModel
//{
//  func playerAuthenticationHandler(vc:UIViewController?, error:Error?)
//  {
//    print("authentication handler:",vc,"\nerror:",error,"\nvalidated:",GKLocalPlayer.local.isAuthenticated)
//  }
//}


extension GameModel : UITableViewDelegate, UITableViewDataSource
{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return opponents.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "opponentCell", for: indexPath)
    
    cell.backgroundColor=UIColor.systemBackground
    
    if let opponent = opponents[safe:indexPath.row]
    {
      cell.textLabel?.text = opponent.name
      cell.detailTextLabel?.text = opponent.lastLossString
      cell.imageView?.image = opponent.image
      
      let layer = cell.contentView.layer
      layer.cornerRadius = 15.0
      layer.borderColor = UIColor.black.cgColor
      layer.borderWidth = 1.0
      
      cell.contentView.backgroundColor =
        ( opponent.lost(after: lastLoss) ? UIColor(named: "losingColor") : UIColor(named:"winningColor") )
    }
    else
    {
      cell.textLabel?.text = "Coding Error"
      cell.detailTextLabel?.text = "oops"
      cell.imageView?.image = UIImage(named: "bug")
    }
    return cell
  }
}
