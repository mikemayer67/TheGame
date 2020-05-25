//
//  TheGameServer.swift
//  GameServer extensions for TheGame
//
//  Created by Mike Mayer on 3/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

extension GameServer
{
  enum Page : String
  {
    case Time  = "time"
    case User  = "user"
    case Email = "email"
    case Error = "error"
  }
  
  enum Action : String
  {
    case Validate = "validate"
    case Connect  = "connect"
    case Create   = "create"
    case Lookup   = "lookup"
    
    case RetieveUsername = "username"
    case ResetPassword   = "password"
  }
  
  func query(_ page:Page, action:Action, args:GameQuery.Args? = nil) -> GameQuery
  {
    var gameArgs : GameQuery.Args = [ "action" : action.rawValue ]
    if let args = args {
      for (key,value) in args { gameArgs[key] = value }
    }
    return query(page.rawValue, args:gameArgs)
  }
  
  func query(_ page:Page, args:GameQuery.Args? = nil) -> GameQuery
  {
    return query(page.rawValue, args:args)
  }
  
  var time : Int?
  {
    var rval : Int?
    if case .Success(let data) = query(.Time).execute().status { rval = data?.time }
    return rval
  }
  
  func sendErrorReport(_ message:[String])
  {
    sendErrorReport( message.joined(separator: "\n") )
  }
  
  func sendErrorReport(_ message:String)
  {
    query("error", args:["details":message]).post { _ in }
  }
}
