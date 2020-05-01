//
//  LoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class LoginViewController: ChildViewController
{
  @IBOutlet weak var facebookButton : UIButton!
  @IBOutlet weak var newAccountButton : UIButton!
  @IBOutlet weak var loginButton : UIButton!
  @IBOutlet weak var whyConnect : UIButton!
    
  override func awakeFromNib()
  {
    super.awakeFromNib()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    debug("viewDidAppear")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    debug("viewWillAppear")
  }
  
  @IBAction func whyFacebook(_ sender : UIButton)
  {
    self.infoPopup(title: "Connection", message:
      ["The Game is a social experience. A connection to the game server enables play with others.",
      "You can either create a Game account or use your Facebook login.",
      "Connecting with Facebook makes it easier to start matches with friends."]
    )
  }
  
  @IBAction func returnToLogin(segue:UIStoryboardSegue)
  {
    self.updateRootView()
  }
  
  @IBAction func returnToLoginAndSwitch(segue:UIStoryboardSegue)
  {
    debug("returnToLoginAndSwitch self:\(self) from:\(segue.source)")
    if let cvc = segue.source as? CreateAccountViewController
    {
      if cvc.switchToAccount {
        performSegue(.loginToAccount)
      }
    }
  }
  
  override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
    debug("unwind:\(unwindSegue) toward:\(subsequentVC)")
  }
}
