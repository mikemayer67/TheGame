//
//  CodeEntryDelegate.swift
//  TheGame
//
//  Created by Mike Mayer on 10/8/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class CodeEntryDelgate : NSObject, UITextFieldDelegate
{
  typealias Callback = ()->()
  
  var onChange : Callback?
  
  init( onChange: Callback? = nil )
  {
    self.onChange = onChange
  }
  
  func textFieldDidEndEditing(_ textField: UITextField)
  {
    onChange?()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
  {
    guard let oldValue = textField.text else { return false }
    
    let isDelete = ( range.length > 0 && string.isEmpty )
        
    var newValue = (oldValue as NSString).replacingCharacters(in: range, with: string)
        
    var newInsertionPoint = range.lowerBound + string.count - string.numWhite
    if range.location > 0, oldValue.count > 0
    {
      let pre = String( oldValue[oldValue.startIndex..<oldValue.index(oldValue.startIndex, offsetBy: range.location)] )
      newInsertionPoint = newInsertionPoint - pre.numWhite
    }
    newInsertionPoint = newInsertionPoint + (newInsertionPoint-1)/2
        
    newValue.removeAll(where: { $0.isWhitespace })
    newValue = newValue.uppercased()
    
    if newValue.count > K.RecoveryCodeLength { return false }
    
    var allowedCharacters = CharacterSet()
    allowedCharacters.insert(charactersIn: " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    if newValue.rangeOfCharacter(from: allowedCharacters.inverted) != nil { return false }
    
    if newValue.count > 2
    {
      let m = (newValue.count-3)/2
      for i in 0...m {
        newValue.insert(" ", at: newValue.index(newValue.startIndex, offsetBy: 2 + 3*i))
      }
    }
    
    let changed = newValue != oldValue
    
    if changed {
      textField.text = newValue
      onChange?()
    }
    
    if (changed || isDelete),
       let pos = textField.position(from: textField.beginningOfDocument, offset: newInsertionPoint)
    {
      textField.selectedTextRange = textField.textRange(from: pos, to: pos)
    }
    
    return false
  }
}
