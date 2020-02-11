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
  @IBOutlet weak var viewController : ViewController!
  
  private(set) var opponents = [Opponent]()

  private(set) var lastLoss : TimeInterval? // game time
  
  private var lossButtonTimer : Timer?
  let unchallangedLossInterval = 60.0 // may lose every hour
  let challengedLossInterval   = 5.0   // may lose one minute after opponent loses
  
  private(set) var allowedToLose = false
  
//  override init()
//  {
//    print("init")
//    lastLoss = UserDefaults.standard.object(forKey: "LastLoss") as? TimeInterval
//    super.init()
//    updateLossButtonTimerr()
//  }
  
  override func awakeFromNib() {
    print("awakFromNib")
    lastLoss = UserDefaults.standard.object(forKey: "LastLoss") as? TimeInterval
    updateLossButtonTimerr()
  }
  
  private func updateLossButtonTimerr() -> Void
  {
    let now = Date()
    var nextLoss : Date?
    
    if let lastLoss = lastLoss
    {
      nextLoss = GameClock.localtime(gametime: lastLoss + unchallangedLossInterval)
      print(nextLoss!.unixtime)
      
      for opponent in opponents {
        if let t = opponent.lastLoss, t > lastLoss {
          nextLoss = GameClock.localtime(gametime: lastLoss + challengedLossInterval)
        }
      }
    }
    
    if let t = lossButtonTimer {
      t.invalidate()
      lossButtonTimer = nil
    }
    
    if let t = nextLoss
    {
      print("Enable Button after",t-now,"seconds")
      lossButtonTimer = Timer.scheduledTimer(withTimeInterval: (t-now), repeats: false)
      { _ in
        print("Enable Button now")
        self.allowedToLose = true
        self.viewController.update()
        self.lossButtonTimer?.invalidate()
        self.lossButtonTimer = nil
      }
    }
    else
    {
      print("Enable Button Immediately")
      allowedToLose = true
      viewController.update()
    }
  }
   
  func add(_ opponent:Opponent) -> Void
  {
    opponents.append(opponent)
  }
  
  func iLostTheGame() -> Void
  {
    lastLoss = GameClock.gametime(localtime: Date() )
    UserDefaults.standard.set(lastLoss, forKey:"LastLoss")
    viewController.update()
  }
}

extension GameModel // @@@ REMOVE
{
  @IBAction func RESET(_ sender: UIButton)  // @@@ REMOVE
  {
    UserDefaults.standard.removeObject(forKey: "LastLoss")
    lastLoss = nil
    viewController.update()
  }
  
  @IBAction func opponentLost(_ sender: UIButton)
  {
    print("opponent",sender.tag,"lost")
    opponents[sender.tag].lastLoss = GameClock.gametime(localtime: Date())
    viewController.update()
    
    updateLossButtonTimerr()
  }
}

extension GameModel : UITableViewDelegate, UITableViewDataSource
{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return opponents.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "opponentCell", for: indexPath)
    
    cell.backgroundColor=UIColor.white
    
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
