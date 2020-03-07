//
//  DictationAwareTextView.swift
//  TheGame
//
//  Created by Mike Mayer on 3/6/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

@objc protocol DictationDelegate
{
  func dictationDidEnd(_ sender:UITextField)
}

class DictationAwareTextView: UITextField
{
  @IBOutlet weak var dictationDelegate : DictationDelegate?

//  override func dictationRecordingDidEnd()
//  {
//    print("dictationRecordingDidEnd")
//    dictationDelegate?.dictationDidEnd(self)
//  }
}
