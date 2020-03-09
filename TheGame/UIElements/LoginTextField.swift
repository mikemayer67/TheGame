//
//  LoginTextField.swift
//  TheGame
//
//  Created by Mike Mayer on 3/7/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

@objc protocol LoginTextFieldDelegate
{
  func loginTextFieldUpdated(_ sender:LoginTextField)
}

@IBDesignable class LoginTextField: UITextField, UITextFieldDelegate
{
  @IBInspectable var allowPasswordCharacters : Bool = false
  @IBOutlet var loginDelegate : LoginTextFieldDelegate?
  
  var validatedText: String?
  var dictationText: String?

  override init(frame: CGRect)
  {
    super.init(frame: frame)
    delegate = self
  }

  required init?(coder: NSCoder)
  {
    super.init(coder: coder)
    delegate = self
  }
  
  // editing started, so save current text
  func textFieldDidBeginEditing(_ textField: UITextField)
  {
    validatedText = text
    dictationText = nil
  }

  // When dictation ends, the text property will be what we *expect*
  //  to show up if *shouldChangeCharactersIn* returns true
  // Validate the dictated string and either cache it or reset it to
  //  the last validated text
  override func dictationRecordingDidEnd()
  {
    dictationText = nil
    
    if let t = text
    {
      let stripped = t.replacingOccurrences(of: " ", with: "")
      if validate(string:stripped) {
        dictationText = stripped
      } else {
        dictationText = validatedText
      }
    }
  }

  // We are going to always return false and handle the update here.
  // If there is dictation input available, use that
  // Otherwise, construct the resultant string updates and validate it.
  //  If good, update the text value
  //  Otherwise, leave the text as is.
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
  {
    var rval    = false
    var changed = false
            
    if let t = dictationText
    {
      // Handle change here, don't let UIKit do it
      text          = t
      validatedText = t
      dictationText = nil
      changed       = true
    }
    else if let value = textField.text
    {
      let fullString = (value as NSString).replacingCharacters(in: range, with: string)
      let strippedString = fullString.replacingOccurrences(of: " ", with: "")
      
      if validate(string:fullString)
      {
        changed = true
        rval    = true
      }
      else if validate(string:strippedString)
      {
        text          = strippedString
        validatedText = strippedString
        changed       = true
      }
    }
    
    if changed { loginDelegate?.loginTextFieldUpdated(self) }
    
    return rval
  }
  
  func textFieldDidEndEditing(_ textField: UITextField)
  {
    loginDelegate?.loginTextFieldUpdated(textField as! LoginTextField)
  }
  
  func validate(string:String) -> Bool
  {
    var allowedCharacters = CharacterSet.alphanumerics
    if allowPasswordCharacters { allowedCharacters.insert(charactersIn: "-!:#$@.") }
    return string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
  }
}
