//
//  LoginModalViewControllers.swift
//  TheGame
//
//  Created by Mike Mayer on 5/10/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class LoginModalViewController: UIViewController, ManagedViewController
{
  @IBOutlet weak var managedView: UIView!
  
  var loginVC  : LoginViewController?
  var container: MultiModalViewController?
  
  private var updateTimer : Timer?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    managedView.layer.cornerRadius = 10
    managedView.layer.masksToBounds = true
    managedView.layer.borderColor = UIColor.gray.cgColor
    managedView.layer.borderWidth = 1.0
  }
  
  @IBAction func cancel(_ sender:UIButton)
  {
    loginVC?.cancel(self)
  }
  
  @discardableResult func checkAll() -> Bool { return true }
}
  
extension LoginModalViewController : LoginTextFieldDelegate, UITextFieldDelegate
{
  func loginTextFieldUpdated(_ sender:LoginTextField)
  {
    startUpdateTimer()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
  {
    startUpdateTimer()
    return true
  }
  
  func startUpdateTimer()
  {
    updateTimer?.invalidate()
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in self.checkAll() }
  }
}

extension MultiModalViewController
{
  func present(_ key:ViewControllerID) { self.present(key.rawValue) }
}
