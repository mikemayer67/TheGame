//
//  CreateAccountViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 3/2/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController
{
  @IBOutlet weak var usernameTextField    : LoginTextField!
  @IBOutlet weak var password1TextField   : LoginTextField!
  @IBOutlet weak var password2TextField   : LoginTextField!
  @IBOutlet weak var displayNameTextField : UITextField!
  @IBOutlet weak var emailTextField       : UITextField!
  @IBOutlet weak var createButton         : UIButton!
  
  @IBOutlet weak var facebookInfoLabel    : UILabel!
  @IBOutlet weak var facebookButton       : UIButton!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    print("username: ",usernameTextField.smartInsertDeleteType.rawValue)
    print("passwd1: ",password1TextField.smartInsertDeleteType.rawValue)
    print("passwd2: ",password2TextField.smartInsertDeleteType.rawValue)
  }
  
  @IBAction func switchToFacebook(_ sender : UIButton)
  {
    performSegue(withIdentifier: "switchToFacebook", sender: sender)
  }
  
  @IBAction func displayInfo(_ sender:UIButton)
  {
    var title : String?
    var message : String?
    switch sender.tag
    {
    case 0:
      title   = "Password"
      message = "Your password must contain at least 8 characters.\n\nIt may contain any combination of letters, numbers, exclamation points, or dashes"
    case 1:
      title   = "Display Name"
      message = "Specifying a display name is optional.\n\nIf provided, this is the name that will be displayed to other players in the game.\n\nIf you choose to not provide a display name, your username will be displayed to other players."
    case 2:
      title   = "Email"
      message = "Specifying your email is optinal.\n\nIf provided, your email will only  be used to recover a lost userid or password. It will not be used for any other purpose.\n\nIf you choose to not provide an email address, it might not be possible to recover your userid or password if lost."
    default:
      break
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert,animated:true)
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
