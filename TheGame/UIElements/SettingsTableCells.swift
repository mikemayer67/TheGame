//
//  SettingsTableCells.swift
//  TheGame
//
//  Created by Mike Mayer on 6/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class SwitchTableCell: UITableViewCell
{
  @IBOutlet weak var label  : UILabel!
  @IBOutlet weak var value : UISwitch!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool)
  {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func handleSwitch(_ sender:UISwitch)
  {
    track("new value: \(sender.isOn)")
  }
  
}
