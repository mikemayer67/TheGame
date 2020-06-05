//
//  SettingsViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 6/4/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
  @IBOutlet weak var settingsTable : UITableView!
  
  @IBAction func done(_ sender:UIButton)
  {
    track("complete settings")
    dismiss(animated: true) {
      track("Settings dimsissed")
    }
  }
}

extension SettingsViewController : UITableViewDelegate, UITableViewDataSource
{
  func numberOfSections(in tableView: UITableView) -> Int { return 3 }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
  {
    switch section {
    case 0: return "Notifications"
    case 1: return "Facebook Connection"
    case 2: return "Account Login"
    default: return nil
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableCell
    cell.label.text = "Toggle \(indexPath)"
    cell.value.isOn = indexPath.row % 2 == 0
    return cell
  }
  
  
}
