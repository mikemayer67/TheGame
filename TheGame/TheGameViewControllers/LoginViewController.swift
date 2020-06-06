//
//  LoginViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 2/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: ChildViewController
{
  @IBOutlet weak var facebookButton : UIButton!
  @IBOutlet weak var newAccountButton : UIButton!
  @IBOutlet weak var loginButton : UIButton!
  @IBOutlet weak var whyConnect : UIButton!
  
  @IBAction func whyFacebook(_ sender : UIButton)
  {
    self.infoPopup(title: "Connection", message:
      ["The Game is a social experience. A connection to the game server enables play with others.",
      "You can either create a Game account or use your Facebook login.",
      "Connecting with Facebook makes it easier to start matches with friends."]
    )
  }
  
  @IBAction func showCreateAccount(_ sender: UIButton)
  {
    showConnectionPopup(.CreateAccount)
  }
  
  @IBAction func showAccountLogin(_ sender: UIButton)
  {
    showConnectionPopup(.AccountLogin)
  }
  
  @IBAction func connectFacebook(_ sender: UIButton)
  {
    let login = LoginManager()
    
    login.logIn(permissions: ["public_profile","user_friends"], from: self) {
      (response, err) in
            
      if err == nil,
        let response = response,
        response.isCancelled == false
      {
        LocalPlayer.connectFacebook(userkey: nil) { (localPlayer) in
          TheGame.shared.me = localPlayer
          self.rootViewController.update()
        }
      }
      else
      {
        self.rootViewController.update()
      }
    }
  }
  
  private func showConnectionPopup(_ id:ModalControllerID)
  {    
    let mmvc = MultiModalViewController()
    let gradient = GradientView(frame: mmvc.view.frame, colors: #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1),#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1))
    gradient.alpha = 0.5
    mmvc.view.addSubview(gradient)
    
    mmvc.delegate = self
    mmvc.modalPresentationStyle = .overCurrentContext
    mmvc.modalTransitionStyle = .crossDissolve
    mmvc.present(id.rawValue)
    self.present(mmvc, animated: true)
  }
}

extension LoginViewController : MultiModalDelegate
{
  func viewController(_ identifier: String, for mmvc: MultiModalViewController) -> ManagedViewController?
  {
    guard let identifier = ModalControllerID(rawValue: identifier) else { return nil }
    switch identifier
    {
    case .AccountLogin:  return AccountLoginViewController(loginVC:self)
    case .CreateAccount: return CreateAccountViewController(loginVC:self)
    case .RetrieveLogin: return ForgotLoginViewController(loginVC: self)
    case .ResetPassword: return ResetPasswordViewController(loginVC: self)
    }
  }
  
  func configure(_ vc: ManagedViewController, for mmvc: MultiModalViewController)
  {
    if let vc = vc as? CreateAccountViewController
    {
      vc.loginVC = self
    }
    else if let vc = vc as? AccountLoginViewController
    {
      vc.loginVC = self
    }
  }
  
  func cancel(_ vc:ManagedViewController)
  {
    dismiss(animated: true)
  }
  
  func completed(_ vc:ManagedViewController)
  {
    dismiss(animated: true)
    {
      self.rootViewController.update()
    }
  }
  
}
