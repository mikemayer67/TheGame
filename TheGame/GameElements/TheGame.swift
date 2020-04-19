//
//  TheGame.swift
//  TheGame
//
//  Created by Mike Mayer on 4/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class TheGame
{
  static let shared = TheGame()
  static let server = GameServer()
  
  var me        : LocalPlayer? = nil
  var opponents = [Opponent]()
  
  fileprivate init()
  {
    self.me = LocalPlayer()
  }
}
