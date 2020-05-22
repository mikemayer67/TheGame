//
//  ModalViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 5/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

enum ModalControllerID : String
{
  case CreateAccount  = "createAccountVC"
  case AccountLogin   = "accountLoginVC"
  case RetrieveLogin  = "retrieveLoginVC"
}

extension MultiModalViewController
{
  func present(_ key:ModalControllerID) { self.present(key.rawValue) }
}


class ModalViewController: UIViewController, ManagedViewController
{  
  private(set) var managedView: UIView!
  private(set) var titleView:   UILabel!
  private(set) var titleRule:   UIView!
  
  enum Style
  {
    static let edgeMargin       = CGFloat(15.0)
    static let topMargin        = CGFloat(10.0)
    static let bottomMargin     = CGFloat(10.0)
    
    static let hruleGap         = CGFloat(5.0)  // vertical gap below a horizontal seperator line
    static let contentGap       = CGFloat(10.0)
    static let fieldGap         = CGFloat(10.0) // vertical gap between entry fields and next header label

    static let entryIndent      = CGFloat(5.0)  // horizontal indent from header label to its associated entry fields
    static let entryGap         = CGFloat(5.0)  // veritcal gap between associated entry fields
    static let infoButtonGap    = CGFloat(2.0)  // vertical gap between info button and associated entry field
    static let textGap          = CGFloat(8.0)  // vertical gap between info text labels
    static let actionGap        = CGFloat(3.0)  // vertical gap between action button and surrounding HRules
    
    static let defaultGapHeight = CGFloat(10.0) // extra vertical gap
  
    static let entryWidth       = CGFloat(225.0)
    static let infoButtonSize   = CGFloat(20.0)
    
    static let titleFont        = UIFont.systemFont(ofSize: 19, weight: .heavy)
    static let headerFont       = UIFont.systemFont(ofSize: 14, weight: .semibold)
    static let infoFont         = UIFont.italicSystemFont(ofSize: 12)
    static let entryFont        = UIFont.systemFont(ofSize: 14)
    static let cancelFont       = UIFont.systemFont(ofSize: 15)
    static let okFont           = UIFont.systemFont(ofSize: 15, weight: .bold)
    static let actionFont       = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let errorFont        = UIFont.systemFont(ofSize: 11)
    
    static let errorColor       = UIColor(named: "dieRed") ?? UIColor.systemRed
  }
  
  var mmvc: MultiModalViewController?
  
  private var updateTimer : Timer?
  
  init(title:String)
  {
    super.init(nibName: nil, bundle: nil)
    self.title = title
  }
  
  required init?(coder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    view.backgroundColor = .clear
    
    managedView = UIView()
    view.addSubview(managedView)
    managedView.translatesAutoresizingMaskIntoConstraints = false
    managedView.backgroundColor = .systemBackground
    managedView.layer.cornerRadius = 10
    managedView.layer.masksToBounds = true
    managedView.layer.borderColor = UIColor.gray.cgColor
    managedView.layer.borderWidth = 1.0
    managedView.alignCenter(to: view)
    managedView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.85).isActive = true

    titleView = UILabel()
    managedView.addSubview(titleView)
    titleView.translatesAutoresizingMaskIntoConstraints = false
    titleView.text = title ?? "???"
    titleView.font = Style.titleFont
    titleView.textColor = UIColor.label
    titleView.packTop(Style.topMargin)
    titleView.alignCenterX(to: managedView)
    
    titleRule = addHRule(below:titleView, gap:Style.topMargin)
  }
}

// MARK:- Component Builders

@objc protocol InfoButtonDelegate
{
  @objc func showInfo(_ sender:UIButton)
}

extension ModalViewController
{
  func addHRule(below refView:UIView, gap:CGFloat = Style.hruleGap) -> UIView
  {
    let hrule = UIView()
    managedView.addSubview(hrule)
    hrule.translatesAutoresizingMaskIntoConstraints = false
    hrule.backgroundColor = .systemGray
    hrule.constrainHeight(1.0)
    hrule.fillX(view: managedView)
    hrule.attachTop(to: refView, offset:gap)
    return hrule
  }
  
  func addHeader(_ text:String,
                 below refView:UIView,
                 gap:CGFloat = Style.fieldGap,
                 indent:CGFloat = 0.0 ) -> UILabel
  {
    let label = UILabel()
    managedView.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = text
    label.font = Style.headerFont
    label.packLeft(Style.edgeMargin + indent)
    label.attachTop(to: refView,offset: gap)
    return label
  }
  
  func addInfoText(_ text:String,
                   below refView:UIView,
                   gap:CGFloat = Style.textGap,
                   indent:CGFloat = 0.0) -> UILabel
  {
    let label = UILabel()
    managedView.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = text
    label.font = Style.infoFont
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.packLeft(Style.edgeMargin + indent)
    label.packRight(Style.edgeMargin)
    label.attachTop(to: refView, offset: gap)
    return label
  }
  
  func addLoginEntry(below refVeiw:UIView,
                     placeholder:String? = nil,
                     password:Bool = false) -> LoginTextField
  {
    let entry = LoginTextField()
    configure(entry:entry, refView: refVeiw)
    entry.placeholder = placeholder ?? "required"
    entry.allowPasswordCharacters = password
    entry.textContentType = (password ? .password : .username )
    entry.isSecureTextEntry = password
    entry.keyboardType = .asciiCapable
    entry.autocorrectionType = .no

    return entry
  }
  
  func addTextEntry(below refVeiw:UIView,
                     placeholder:String? = nil,
                     email:Bool = false) -> UITextField
  {
    let entry = UITextField()
    configure(entry:entry, refView: refVeiw)
    entry.placeholder = placeholder ?? "optional"
    entry.textContentType = (email ? .emailAddress : .none)
    entry.keyboardType = (email ? .emailAddress : .asciiCapable )
    entry.autocorrectionType = .no
    return entry
  }
  
  private func configure(entry:UITextField, refView:UIView)
  {
    managedView.addSubview(entry)
    entry.translatesAutoresizingMaskIntoConstraints = false
    entry.font = Style.entryFont
    entry.autocapitalizationType = .none
    entry.borderStyle = .roundedRect
    entry.clearButtonMode = .always
    entry.minimumFontSize = 17.0
    entry.adjustsFontSizeToFitWidth = true

    entry.minWidth(Style.entryWidth)
    entry.attachTop(to: refView,offset: Style.entryGap)
    entry.packLeft(Style.edgeMargin + Style.entryIndent)
    entry.packRight(Style.edgeMargin)
  }
  
  func addCancelButton(title:String = "Cancel") -> UIButton
  {
    let button = UIButton(type: .system)
    managedView.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(title, for: .normal)
    button.setTitleColor(.systemRed, for: .normal)
    button.titleLabel?.font = Style.cancelFont
    button.packLeft(Style.edgeMargin)
    button.packBottom(Style.bottomMargin)
    return button
  }
  
  func addOkButton(title:String = "OK") -> UIButton
  {
    let button = UIButton(type: .system)
    managedView.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = Style.okFont
    button.packRight(Style.edgeMargin)
    button.packBottom(Style.bottomMargin)
    return button
  }
  
  func addInfoButton(to entry:UITextField, target:InfoButtonDelegate) -> UIButton
  {
    let button = UIButton(type: .infoLight)
    managedView.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.constrainWidth(Style.infoButtonSize)
    button.constrainHeight(Style.infoButtonSize)
    button.alignRight(to: entry)
    button.attachBottom(to: entry,offset: Style.infoButtonGap)
    button.addTarget(target, action: #selector(InfoButtonDelegate.showInfo(_:)), for: .touchUpInside)
    return button
  }
  
  func addActionButton(title:String, below refView:UIView, gap:CGFloat = Style.actionGap) -> UIButton
  {
    let button = UIButton(type:.system)
    managedView.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = Style.actionFont
    button.fillX(view: managedView)
    button.attachTop(to: refView, offset: gap)
    return button
  }
  
  func addErrorLabel(to refView:UIView) -> UILabel
  {
    let label = UILabel()
    managedView.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = nil
    label.font = Style.errorFont
    label.textColor = Style.errorColor
    if let entry = refView as? UITextField
    {
      label.alignRight(to: entry)
      label.attachBottom(to: entry)
    }
    else
    {
      label.attachRight(to: refView, offset:5.0)
      label.alignCenterY(to: refView)
    }
    return label
  }
  
  func addGap(below refView: UIView, gap height:CGFloat = Style.defaultGapHeight) -> UIView
  {
    let gap = UIView()
    managedView.addSubview(gap)
    gap.translatesAutoresizingMaskIntoConstraints = false
    gap.attachTop(to: refView)
    gap.alignLeft(to: managedView)
    gap.alignRight(to: managedView)
    gap.constrainHeight(height)
    return gap
  }
}

