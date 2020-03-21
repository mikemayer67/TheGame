//
//  StartupViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum ViewEncodingError : Error
{
  case failedToDecode
}

class StartupViewController: UIViewController
{
  @IBOutlet weak var facebookButton : UIButton!
  @IBOutlet weak var newAccountButton : UIButton!
  @IBOutlet weak var reconnectButton : UIButton!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    let gs = GameServer.shared
    print(gs.fbToken?.tokenString ?? "no token")
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  @IBAction func connectWithFacebook(_ sender : UIButton)
  {
    performSegue(withIdentifier: "facebookLogin", sender: sender)
  }
  
  @IBAction func createNewAccount(_ sender : UIButton)
  {
    performSegue(withIdentifier: "createAccount", sender: sender)
  }
  
  @IBAction func reconnectToAccount(_ sender : UIButton)
  {
    performSegue(withIdentifier: "reconnect", sender: sender)
  }
  
  @IBAction func whyConnect(_ sender : UIButton)
  {
    print("WhyConnect")
    InfoAlert.connectInfo.display(over: self)
  }
  
  @IBAction func unwindToStartup(unwindSegue:UIStoryboardSegue)
  {
    print("unwind to startup")
  }
  
  func transitionToGame(animate:Bool)
  {
    guard let w = view.window else { fatalError("Attempting to transition from unwindowed view") }
    
    let gameStoryBoard = UIStoryboard(name: "GameBoard", bundle: nil)
    let gameViewController = gameStoryBoard.instantiateInitialViewController()
   
    w.rootViewController = gameViewController
    if animate
    {
      UIView.transition(with: w, duration: 0.5, options: .transitionCurlUp, animations: {})
    }
  }
  
  func update(animated:Bool) -> Void
  {
    // @@@ TODO Check login status
  }
}
