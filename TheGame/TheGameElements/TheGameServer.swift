//
//  TheGameServer.swift
//  GameServer extensions for TheGame
//
//  Created by Mike Mayer on 3/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

// MARK:- Query Support Structures

enum GameQueryKey : String
{
  case Time      = "time"
  case Userid    = "userid"
  case FBID      = "fbid"
  case Userkey   = "userkey"
  case Username  = "username"
  case Password  = "password"
  case Alias     = "alias"
  case Email     = "email"
  case EmailVal  = "email_validation"
  case Lastloss  = "last_loss"
  case Validated = "Y"
  case Dropped   = "dropped"
  case Updated   = "updated"
  case Scope     = "scope"
  case Notify    = "notify"
}

enum EmailStatus
{
  case Unknown
  case NoEmail
  case HasValidatedEmail
  case HasUnvalidatedEmail
}

typealias GameQueryArgs = [GameQueryKey:String]

extension GameServer
{
  enum Page : String
  {
    case Time = "time"
    case User = "user"
  }
  
  enum Action : String
  {
    case Validate = "validate"
    case Connect  = "connect"
  }
  
  var time : Int? { query(.Time).time }
  
  func query(_ page:Page, action:Action? = nil, gameArgs:GameQueryArgs? = nil, completion: @escaping QueryCompletion)
  {
    let serverArgs = convertArgs(from:gameArgs, action:action)
    query(page.rawValue, args: serverArgs, completion: completion)
  }
  
  func query(_ page:Page, action:Action? = nil, gameArgs:GameQueryArgs? = nil) -> QueryResponse
  {
    let serverArgs = convertArgs(from:gameArgs, action:action)
    return query(page.rawValue, args: serverArgs)
  }

  func convertArgs(from gameArgs:GameQueryArgs?, action:Action?) -> QueryArgs?
  {
    guard ( gameArgs != nil || action != nil ) else { return nil }
    
    var serverArgs = QueryArgs()
    if let action = action
    {
      serverArgs["action"] = action.rawValue
    }
    if let args = gameArgs {
      for (key,value) in args {
        serverArgs[key.rawValue] = value
      }
    }
    
    return serverArgs
  }
}

extension QueryResponse
{
  enum ReturnCode : Int
  {
    case InvalidCode           = -4
    case MissingCode           = -3
    case InvalidURI            = -2
    case FailedToConnect       = -1
    case Success               =  0
    case UserExists            =  1
    case InvalidUserkey        =  2
    case InvalidUsername       =  3
    case InvalidUserkeyFBID    =  4
    case IncorrectUsername     =  5
    case IncorrectPassword     =  6
    case FailedToCreateFBID    =  7
    case FailedToCreateUser    =  8
    case FailedToUpdateUser    =  9
    case NoValidatedEmail      = 10
    
    init(_ rc:Int?)
    {
      if let rc = rc {
        self = ReturnCode(rawValue: rc) ?? .InvalidCode
      } else {
        self = .MissingCode
      }
    }
  }
  
  func getInt   (_ key:GameQueryKey) -> Int?    { data?[key.rawValue] as? Int    }
  func getDouble(_ key:GameQueryKey) -> Double? { data?[key.rawValue] as? Double }
  func getString(_ key:GameQueryKey) -> String? { data?[key.rawValue] as? String }
  func getAny   (_ key:GameQueryKey) -> Any?    { data?[key.rawValue]            }
  
  func getBool  (_ key:GameQueryKey) -> Bool?
  {
    guard let v = getInt(key) else { return nil }
    return ( v != 0 )
  }
  
  var returnCode : ReturnCode { ReturnCode(rc) }
  
  var time        : Int?    { getInt(.Time) }
  var userkey     : String? { getString(.Userkey) }
  var alias       : String? { getString(.Alias) }
  var email       : String? { getString(.Email) }
  var lastLoss    : Int?    { getInt(.Lastloss) }
  
  var hasUserkey  : Bool?   { getBool(.Userkey) }
  var hasUsername : Bool?   { getBool(.Username) }
  var hasFacebook : Bool?   { getBool(.FBID) }
  
  var emailStatus : EmailStatus
  {
    guard let v = getBool(.Email) else { return .NoEmail }
    return ( v ? .HasUnvalidatedEmail : .HasValidatedEmail )
  }
}
