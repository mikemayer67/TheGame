//
//  SettingsTableCells.swift
//  TheGame
//
//  Created by Mike Mayer on 6/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class SectionHeadingView : UITableViewHeaderFooterView
{
  static let reuseIdentifier: String = String(describing: self)

  private(set) var titleLabel : UILabel!
  private(set) var infoLabel  : UILabel!
  
  var title : String? {
    get { return titleLabel.text }
    set { titleLabel.text = newValue }
  }

  var info : String? {
    get { return infoLabel.text }
    set { infoLabel.text = newValue }
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    titleLabel = UILabel()
    infoLabel = UILabel()
    
    let titleFontSize : CGFloat = 15.0
    titleLabel.font = UIFont(
      descriptor:UIFont.systemFont(ofSize: titleFontSize, weight: .heavy).fontDescriptor.addingAttributes(
        [.featureSettings: [
          [ UIFontDescriptor.FeatureKey.featureIdentifier : kUpperCaseType,
            UIFontDescriptor.FeatureKey.typeIdentifier : kUpperCaseType ],
          [
            UIFontDescriptor.FeatureKey.featureIdentifier : kLowerCaseType,
            UIFontDescriptor.FeatureKey.typeIdentifier: kLowerCaseSmallCapsSelector ]
        ] ] ), size: titleFontSize )
    
    infoLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .light)
    infoLabel.textColor = UIColor.systemGray
    
    contentView.addSubview(titleLabel)
    contentView.addSubview(infoLabel)
    contentView.backgroundColor = UIColor.systemGray6
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    infoLabel.translatesAutoresizingMaskIntoConstraints = false

    infoLabel.numberOfLines = 0
    
    infoLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18.0).isActive = true
    infoLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 12.0).isActive = true
    infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    infoLabel.text = "This is some sample info text that may need to span multiple line.\nPossibly with newlines."
    
    titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12.0).isActive = true
    titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 12.0).isActive = true
    titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -1.0).isActive = true
    titleLabel.text = "Title"
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
}

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
