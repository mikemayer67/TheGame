//
//  LoginTextField.swift
//  TheGame
//
//  Created by Mike Mayer on 3/7/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

@IBDesignable class LoginTextField: UITextField, UITextFieldDelegate
{
  enum LoginType : Int
  {
    case Username = 0
    case Password = 1
    case ResetCode = 2
  }
  
  var type : LoginType = .Username
  
  var validatedText: String?
  var dictationText: String?
  
  var changeCallback : (()->())?
  
  init(frame: CGRect, type:LoginType)
  {
    self.type = type
    super.init(frame: frame)
    delegate = self
  }
  
  convenience init(type:LoginType)
  {
    self.init(frame:CGRect.null, type:type)
  }

  override required init(frame: CGRect)
  {
    super.init(frame: frame)
    delegate = self
  }

  required init?(coder: NSCoder)
  {
    self.type = .Username
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
      var fullString = (value as NSString).replacingCharacters(in: range, with: string)
      
      if case .ResetCode = self.type { fullString = fullString.uppercased() }
      
      let strippedString = fullString.replacingOccurrences(of: " ", with: "")
      
      if validate(string:fullString)
      {
        changed = true
        rval    = true
        
        if case .ResetCode = self.type { text = fullString }
      }
      else if validate(string:strippedString)
      {
        text          = strippedString
        validatedText = strippedString
        changed       = true
      }
    }
    
    if changed { changeCallback?() }
    
    return rval
  }
  
  func textFieldDidEndEditing(_ textField: UITextField)
  {
    changeCallback?()
  }
  
  func validate(string:String) -> Bool
  {
    var allowedCharacters : CharacterSet
    
    switch type
    {
    case .Username:
      allowedCharacters = CharacterSet.alphanumerics
    case .Password:
      allowedCharacters = CharacterSet.alphanumerics
      allowedCharacters.insert(charactersIn: "-!:#$@.")
    case .ResetCode:
      allowedCharacters = CharacterSet()
      allowedCharacters.insert(charactersIn: "0123456789 ")
    }
        
    return string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
  }
}
