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
  case Salt      = "salt"
}

enum EmailStatus
{
  case Unknown
  case NoEmail
  case HasValidatedEmail
  case HasUnvalidatedEmail
}

typealias GameQueryArgs = [GameQueryKey:String]

extension QueryResponse
{
  static let UserExists            =  1
  static let InvalidUserkey        =  2
  static let InvalidUsername       =  3
  static let InvalidUserkeyFBID    =  4
  static let IncorrectUsername     =  5
  static let IncorrectPassword     =  6
  static let FailedToCreateFBID    =  7
  static let FailedToCreateUser    =  8
  static let FailedToUpdateUser    =  9
  static let NoValidatedEmail      = 10
  static let InvalidEmail          = 11
  
  static let strings : [Int:String] =
  [
    MissingCode        : "No Return Code",
    InvalidCode        : "Invalid Code",
    Success            : "Success",
    UserExists         : "User Exists",
    InvalidUserkey     : "Invalid Userkey",
    InvalidUsername    : "Invalid Username",
    InvalidUserkeyFBID : "Invalid Userkey FBID",
    IncorrectUsername  : "Incorrect Username",
    IncorrectPassword  : "Incorrect Password",
    FailedToCreateFBID : "Failed To Create FBID",
    FailedToCreateUser : "Failed To Create User",
    FailedToUpdateUser : "Failed To Update User",
    NoValidatedEmail   : "NoValidated Email",
    InvalidEmail       : "Invalid Email"
  ]
  
  var failure : String
  {
    switch self
    {
    case .Success(_):           return "Success"
    case .FailedToConnect:      return "Failed to Connect"
    case .InvalidURI(let url):  return "Invalid URI: \(url.absoluteString)"
      
    case .ServerFailure(let rc), .QueryFailure(let rc, _):
      return QueryResponse.strings[rc] ?? "Invalid Code"
    }
  }
}

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
  
  var time : Int?
  {
    let response = query(.Time)
    guard case .Success(let data) = response else { return nil }
    return data?.time
  }
  
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
  
  func sendErrorReport(_ message:[String])
  {
    sendErrorReport(message.joined(separator: "\n"))
  }
  
  func sendErrorReport(_ message:String)
  {
    post("error", args: ["details":message] ) { (_,_) in }
  }
}

extension HashData
{
  func getInt   (_ key:GameQueryKey) -> Int?    { self[key.rawValue] as? Int    }
  func getDouble(_ key:GameQueryKey) -> Double? { self[key.rawValue] as? Double }
  func getString(_ key:GameQueryKey) -> String? { self[key.rawValue] as? String }
  func getAny   (_ key:GameQueryKey) -> Any?    { self[key.rawValue]            }
  
  func getBool  (_ key:GameQueryKey) -> Bool?
  {
    guard let v = getInt(key) else { return nil }
    return ( v != 0 )
  }
    
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
    return ( v ? .HasValidatedEmail : .HasUnvalidatedEmail )
  }
}
