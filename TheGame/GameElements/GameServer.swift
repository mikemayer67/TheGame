//
//  GameServer.swift
//  TheGame
//
//  Created by Mike Mayer on 3/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

import FacebookCore
import FacebookLogin

protocol GameServerListener
{
  
}

class GameServer
{
  static let shared = GameServer()
  
  var username : String?
  var password : String?
  var fbToken : AccessToken?
  
  private init()
  {
    fbToken = AccessToken.current
  }
  
  func hasConnection() -> Bool
  {
    return true
  }
}