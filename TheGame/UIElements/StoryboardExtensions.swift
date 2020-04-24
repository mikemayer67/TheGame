//
//  StoryboardExtensions.swift
//  TheGame
//
//  Created by Mike Mayer on 4/22/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

extension UIStoryboard
{
  convenience init(_ id : StoryBoardID)
  {
    self.init(name: id.rawValue, bundle: nil)
  }
  
  func instantiateViewController(_ id : ViewControllerID) -> UIViewController
  {
    return self.instantiateViewController(withIdentifier: id.rawValue)
  }
}
