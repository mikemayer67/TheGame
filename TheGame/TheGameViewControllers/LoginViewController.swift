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
 - CreatePlayer
 - PlayerReconnect
 - RetreiveLogin
 - ResetPassword
 */
enum ModalControllerID : String
{
  case CreatePlayer     = "createPlayerVC"
  case PlayerReconnect  = "playerReconnectVC"
  case ReconnectKey     = "reconnectKeyVC"
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
 - reconnecting as an existing player
 - connecting using Facebook
 - creating a player
*/
class LoginViewController: ChildViewController
{
  @IBOutlet weak var facebookButton : UIButton!
  @IBOutlet weak var newPlayerButton : UIButton!
  @IBOutlet weak var playerReconnectButton : UIButton!
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
  @IBAction func showCreatePlayer(_ sender: UIButton)
  {
    showConnectionPopup(.CreatePlayer)
  }
  
  ///Raises the modal dialog for reconnecting to an existing
  @IBAction func showPlayerReconnect(_ sender: UIButton)
  {
    showConnectionPopup(.PlayerReconnect)
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
    case .CreatePlayer:    return CreatePlayerViewController(loginVC:self)
    case .PlayerReconnect: return ReconnectViewController(loginVC:self)
    case .ReconnectKey:    return ReconnectKeyViewController(loginVC: self)
    }
  }
  
  func configure(_ vc: ManagedViewController, for mmvc: MultiModalViewController)
  {
    debug("LoginViewController.configure(vc:\(vc)")
  }
}
