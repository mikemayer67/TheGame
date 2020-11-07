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
  
  weak var me : LocalPlayer?
  
  var foregroundObserver : NSObjectProtocol?
  
  @IBAction func done(_ sender:UIButton)
  {
    track("complete settings")
    dismiss(animated: true) {
      track("Settings dimsissed")
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    guard let me = TheGame.shared.me else {
      fatalError("SettingsViewController should only be shown if TheGame.LocalPlayer is set")
    }
    self.me = me
    
//    debug("Showing settings for \(me)")
//    debug("  name = \(me.name ?? "???")")
//    debug("  fbid = \(me.fbid ?? "nil")")
//
//    let isFacebook = me.fbid != nil
//    let hasEmail = me.email != nil
//    let hasValidatedEmail = me.email?.validated ?? false
//
//    if let email = me.email { debug(" email = \(email.address)  \(email.validated ? "validated" : "unvalidated")")
//    }  else { debug(" email = nil") }
//
//    debug("state: \(isFacebook) \(hasEmail) \(hasValidatedEmail)")
//
//    debug("notifications: \((RemoteNotificationManager.shared.enabled ?? false) ? "enabled" : "disabled") \(RemoteNotificationManager.shared.active ? "active" : "inactive")")
//
    settingsTable.register(SectionHeadingView.self, forHeaderFooterViewReuseIdentifier: SectionHeadingView.reuseIdentifier)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    if self.foregroundObserver == nil
    {
      self.foregroundObserver = NotificationCenter.default.addObserver(
        forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil )
        { _ in self.refreshTable() }
    }
  }
    
  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)
    if let observer = self.foregroundObserver {
      NotificationCenter.default.removeObserver(observer)
      self.foregroundObserver = nil
    }
  }
  
  func refreshTable()
  {
    debug("SVC::refreshTable")
  }
}

  
extension SettingsViewController : UITableViewDelegate, UITableViewDataSource
{
  func numberOfSections(in tableView: UITableView) -> Int
  {
    if let me = TheGame.shared.me
    {
    debug("Table update for Local Player: userkey: \(me.userkey)" )
    }

    return 3
  }
  
//  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
//  {
//    switch section {
//    case 0: return "Notifications"
//    case 1: return "Facebook Connection"
//    case 2: return "Account Login"
//    default: return nil
//    }
//  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return 50.0
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
  {
    var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeadingView.reuseIdentifier) as? SectionHeadingView
    if header == nil
    {
      header = UITableViewHeaderFooterView(reuseIdentifier:  SectionHeadingView.reuseIdentifier) as? SectionHeadingView
      header?.prepareForReuse()
    }
    
    switch section {
    case 0:
      header?.title = "Notifications"
    case 1:
      header?.title = "Facebook"
    case 2:
      header?.title = "Player Info"
    default: return nil
    }
    
    return header
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
