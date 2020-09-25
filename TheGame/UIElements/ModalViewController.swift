//
//  ModalViewController.swift
//  TheGame
//
//  Created by Mike Mayer on 5/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
 Subclass of UIViewContrller and ManagedViewController which serves as a base class
 for building modal view controller views with a common look and feel and which
 can be managed by the MultiModalViewController.
 
 It defines layout size/offset distances, fonts, and colors, which if used properly
 will provide the consistent look and feel between the modal views.
 
 An unsubclassed ModalViewController contains only the title (at the top of the
 modal view) and a horizontal rule just below the title.  Subclasses add elements
 to these to complete the modal view.  They will probably need to reference *titleView*,
 the view which contains the horiontal rule for laying out new elements.
 
 It defines a number component builder functions which simplify the process of
 building up the content of the modal view and ensure consistency of function for
 similar elements.
 - addHRule: creates a *UIView* that displays a horizontal line
 - addHeader: creates a *UILabel* that displays header text
 - addInfoText: creates a *UILabel* that displays information text
 - addLoginEntry: creates a *LoginTextField*
 - addTextEntry: creates a *UITextField*
 - configure: provides the common look and feel to a *UITextField*
 - addCancelButton: creates a *UIButton* to allow the user to cancel the current action
 - addOkButton: creates a *UIButton* to allow the user to proceed with the current action
 - addInfoButton: creates a *UIButton* which the user can click to get additional info
 - addActionButton: creates a *UIButton* whose action must be defined in the modal view subclass
 - addErrorLabel: creates UILabel that with formatting designed to identify a problem
 - addGap: creates an empty *UIView* for the purpose of adding whitespace to the modal view
 */
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

/**
 Protocol which indicates the class supports the showInfo method.
 This is needed to support info buttons constructed by the *ModalViewController::addInfoButton*
 */
@objc protocol InfoButtonDelegate
{
  @objc func showInfo(_ sender:UIButton)
}


extension ModalViewController
{
  /**
   Creates a *UIView* that displays a horizontal line that spans the with of the modal view.
   - Parameter refView: *UIView* that the hrule should be displayed below
   - Parameter gap: Distance between the refernce *UIView* and the rule.
   */
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
  
  /**
   Creates a *UILabel* that displays a header at the top of the modal view.
   - Parameter text: text to dispaly in the header
   - Parameter refView: *UIView* that the header should be displayed below
   - Parameter gap: Distance between the refernce *UIView* and the header text.
   - Parameter indent: Indentation of the header relative to the standard margin
  */
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
  
  /**
   Creates a *UILabel* that displays information text
   - Parameter text: informational text to dispaly
   - Parameter refView: *UIView* that the header should be displayed below
   - Parameter gap: Distance between the refernce *UIView* and the info text.
   - Parameter indent: Indentation of the header relative to the standard margin
   */
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
  
  /**
   Creates a *LoginTextField*
   - Parameter refView: *UIView* that the header should be displayed below
   - Parameter placeholder: Text that should appear in the box when it is "empty"
   - Parameter type: LogintTextField.LoginType (Username, Password, etc.)
   */
  func addLoginEntry(below refVeiw:UIView,
                     placeholder:String? = nil,
                     type:LoginTextField.LoginType = .Username) -> LoginTextField
  {
    let entry = LoginTextField()
    configure(entry:entry, refView: refVeiw)
    entry.placeholder = placeholder ?? "required"
    entry.type = type
    switch type
    {
    case .Username:
      entry.textContentType   = .username
      entry.keyboardType      = .asciiCapable
    case .Password:
      entry.textContentType   = .password
      entry.keyboardType      = .asciiCapable
      entry.isSecureTextEntry = true
    case .ResetCode:
      entry.textContentType   = .username
      entry.keyboardType      = .numberPad
    }
    entry.autocorrectionType = .no

    return entry
  }
  
  /**
   Creates a *UITextField*.
   
   The *configure* method will be invoked on the returned text field to
   provide the common look and feel.
   - Parameter refView: *UIView* that the header should be displayed below
   - Parameter placeholder: Text that should appear in the box when it is "empty"
   - Parameter email: Used to determine type of keyboard to display
   */
  func addTextEntry(below refVeiw:UIView,
                     placeholder:String? = nil,
                     required:Bool = false,
                     email:Bool = false) -> UITextField
  {
    let entry = UITextField()
    configure(entry:entry, refView: refVeiw)
    entry.placeholder = placeholder ?? (required ? "required" : "optional")
    entry.textContentType = (email ? .emailAddress : .none)
    entry.keyboardType = (email ? .emailAddress : .asciiCapable )
    entry.autocorrectionType = .no
    return entry
  }
  
  /**
   Provides the common look and feel to a *UITextField*.
   
   This should be used for
   any *UITextField* that was addded to the modal view by any means other than the
   *addTextEntry* method.
   - Parameter entry: *UITextField* to be configured
   - Parameter refView: *UIView* that the header should be displayed below
   */
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
  
  /**
   - Creates a *UIButton* to allow the user to cancel the current action.
   
   The button will be positioned in the lower left corner of the modal view.
   
   Note that the creation of the button does not provide any functionality.  That must be
   handled by the modal view subclass after constructing the button.
   
   - Parameter title: text to display on the button
   */
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
  
  /**
   Creates a *UIButton* to allow the user to proceed with the current action
   
   The button will be positioned in the lower right corner of the modal view.
   
   Note that the creation of the button does not provide any functionality.  That must be
   handled by the modal view subclass after constructing the button.
   
   - Parameter title: text to display on the button
   */
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
  
  /**
   Creates a *UIButton* attachec to a *UITextField* which the user can click to get additional info
   about the text field
   
   The button will display the *infoLight* icon.
   
   The button will appear just above and right aligned with the text field.
   
   - Parameter entry: the *UITextFiled* that the info button is attached to
   - Parameter target: an object which will provide the info text.  Must conform to the *InfoButtonDelegate* protocol.
   */
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
  
  /**
   Creates a *UIButton* whose action must be defined in the modal view subclass
   
   Note that the creation of the button does not provide any functionality.  That must be
   handled by the modal view subclass after constructing the button.
   
   - Parameter title: text to display on the button
   - Parameter refView: *UIView* that the button should be displayed below
   - Parameter gap: Distance between the refernce *UIView* and the info text
   */
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
  
  /**
   Creates UILabel that with formatting designed to identify a problem
   
   If the reference view is a UITextView, the text will appear just above and right aligned
   with the text field.  Otherwise, it will appear vertically aligned and to the right of
   the reference view.
   
   - Parameter refView: *UIView* that the text should be attached to
   */
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
  
  /**
   Creates an empty *UIView* for the purpose of adding whitespace to the modal view
   - Parameter refView: *UIView* that the text should be attached to
   - Parameter height: how big the gap should be
   */
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

