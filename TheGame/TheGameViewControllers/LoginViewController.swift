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

/**
 The enum contains the list of IDs for the modal view contollers used in TheGame
 ## Values
 - CreateAccount
 - RecoverAccount
 - RecoveryKey
 - RecoverOptions
 */
enum ModalControllerID : String
{
  case CreateAccount    = "createAccountVC"
  case RecoverAccount   = "recoverAccountVC"
  case RecoveryKey      = "recoveryKeyVC"
  case RecoveryOptions  = "recoveryOptionsVC"
}


extension MultiModalViewController
{
  /**
  Extends MultiModalViewController by adding a present method wrapper which
  recognizes ModalControllerIDs. It simply conferts the enum to the associated
  string value and passes that on to the "real" present method.
  */
  func present(_ key:ModalControllerID) { self.present(key.rawValue) }
}

/**
 View controller displayed when there is a connection to the game server but
 the local user has not yet been identified.
 
 The view provides options (buttons) for:
 - connecting using Facebook
 - creating a new account
 - recovering an existing account
*/
class LoginViewController: ChildViewController
{
  @IBOutlet weak var facebookButton : UIButton!
  @IBOutlet weak var newAccountButton : UIButton!
  @IBOutlet weak var recoverButton : UIButton!
  @IBOutlet weak var whyConnect : UIButton!
  
  /// Raises popup explaining the benefits of connecting with Facebook
  @IBAction func whyFacebook(_ sender : UIButton)
  {
    self.infoPopup(title: "Connection", message:
      ["The Game is a social experience. A connection to the game server enables play with others.",
      "You can either create a Game account or use your Facebook login.",
      "Connecting with Facebook makes it easier to start matches with friends."]
    )
  }
  
  ///Raises the modal dialog for creaing a new player
  @IBAction func showCreateAccount(_ sender: UIButton)
  {
    showConnectionPopup(.CreateAccount)
  }
  
  ///Raises the modal dialog for recovering an existing account
  @IBAction func showRecovery(_ sender: UIButton)
  {
    showConnectionPopup(.RecoveryOptions)
  }
  
  /**
   Uses the FB API to connect using Facebook account
   
   On completion, the update method of *RootViewController* is invoked,
   which will start the game view if connection was succesful.
  */
  @IBAction func connectFacebook(_ sender: UIButton)
  {
    let login = LoginManager()
    
    login.logIn(permissions: ["public_profile","user_friends"], from: self) {
      (response, err) in
            
      if err == nil,
        let response = response,
        response.isCancelled == false
      {
        LocalPlayer.connectFacebook() { (localPlayer) in
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
  
  /**
   Raises the specified modal view controller using MultiModalViewController
   - Parameter id: modal view controller ID
   */
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

  /// Simply dismisses the current modal view
  func cancel()
  {
    dismiss(animated: true)
  }
  
  /// Dismisses the current modal view and invokes the update method on *RootViewController*
  func completed()
  {
    dismiss(animated: true)
    {
      self.rootViewController.update()
    }
  }
  
}

extension LoginViewController : MultiModalDelegate
{
  func viewController(_ identifier: String, for mmvc: MultiModalViewController) -> ManagedViewController?
  {
    guard let identifier = ModalControllerID(rawValue: identifier) else { return nil }
    switch identifier
    {
    case .CreateAccount:    return CreateAccountViewController(loginVC:self)
    case .RecoverAccount:   return RecoverAccountViewController(loginVC:self)
    case .RecoveryKey:      return RecoveryKeyViewController(loginVC: self)
    case .RecoveryOptions:  return RecoveryOptionsViewController(loginVC: self)
    }
  }
  
  func configure(_ vc: ManagedViewController, for mmvc: MultiModalViewController)
  {
    debug("LoginViewController.configure(vc:\(vc)")
  }
}
