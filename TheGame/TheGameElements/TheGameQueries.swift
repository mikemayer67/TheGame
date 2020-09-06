//
//  TheGameQueries.swift
//  TheGame
//
//  Created by Mike Mayer on 5/16/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

enum QueryKey
{
  static let Alias      = "alias"
  static let Dropped    = "dropped"
  static let Email      = "email"
  static let EmailVal   = "email_validation"
  static let FBID       = "fbid"
  static let LastLoss   = "last_loss"
  static let MatchStart = "match_start"
  static let Matches    = "matches"
  static let Name       = "name"
  static let Notify     = "notify"
  static let Password   = "password"
  static let ResetCode  = "reset"
  static let Salt       = "salt"
  static let Scope      = "scope"
  static let Time       = "time"
  static let Updated    = "updated"
  static let Userid     = "userid"
  static let Userkey    = "userkey"
  static let Username   = "username"
  static let Validated  = "Y"
}

enum EmailStatus
{
  case Unknown
  case NoEmail
  case HasValidatedEmail
  case HasUnvalidatedEmail
  
  init(_ validatedEmail : Bool?)
  {
    if let v = validatedEmail {
      self = ( v ? .HasValidatedEmail : .HasUnvalidatedEmail )
    } else {
      self = .NoEmail
    }
  }
}

extension HashData
{
  var time        : Int?    { getInt(QueryKey.Time) }
  var userkey     : String? { getString(QueryKey.Userkey) }
  var alias       : String? { getString(QueryKey.Alias) }
  var email       : String? { getString(QueryKey.Email) }
  var lastLoss    : Int?    { getInt(QueryKey.LastLoss) }
  
  var hasUserkey  : Bool?   { getBool(QueryKey.Userkey) }
  var hasUsername : Bool?   { getBool(QueryKey.Username) }
  var hasFacebook : Bool?   { getBool(QueryKey.FBID) }
  
  var emailStatus : EmailStatus
  {
    return EmailStatus( getBool(QueryKey.Email) )
  }
}

extension GameQuery.Status
{
  static let UserExists            =  1
  static let InvalidUserkey        =  2
  static let InvalidUsername       =  3
  static let InvalidFBID           =  4
  static let IncorrectUsername     =  5
  static let IncorrectPassword     =  6
  static let FailedToCreateFBID    =  7
  static let FailedToCreateUser    =  8
  static let FailedToUpdateUser    =  9
  static let NoValidatedEmail      = 10
  static let InvalidEmail          = 11
  
  static let strings : [Int:String] =
  [
    MissingData        : "Missing Data",
    MissingCode        : "No Return Code",
    InvalidCode        : "Invalid Code",
    Success            : "Success",
    UserExists         : "User Exists",
    InvalidUserkey     : "Invalid Userkey",
    InvalidUsername    : "Invalid Username",
    InvalidFBID        : "Invalid Facebook ID",
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
    case .QueryError(let err):  return err
    case .FailedToConnect:      return "Failed to Connect"
    case .InvalidURL(let url):  return "Invalid URL: \(url.absoluteString)"
      
    case .ServerFailure(let rc), .QueryFailure(let rc, _):
      return GameQuery.Status.strings[rc] ?? "Invalid Code"
    }
  }
}
  
extension GameQuery
{
  var internalError : String?
  {
    var error = ""
    switch status
    {
    case .Success(_):
      return nil
    case .none:
      error = "Query results evaluated before executing it."
    case .FailedToConnect:
      error = "Failed to connect to server."
    case .InvalidURL(_):
      error = "Invalid URL"
    case .ServerFailure(let rc):
      let rcs = GameQuery.Status.strings[rc] ?? "Unknown code \(rc)"
      error = "Server was unable to process URL (\(rcs))"
    case .QueryFailure(let rc, _):
      let rcs = GameQuery.Status.strings[rc] ?? "Unknown code \(rc)"
      error = "Unexpected result returned from server (\(rcs))"
    case .QueryError(let err):
      error = err
    }
    
    error += "\n"
    
    if let server = server { error += "\nServer: \(server.host)" }
    if let args   = args   { error += "\nArgs: \(args)"   }
    if let url    = url    { error += "\nURL: \(url)"    }
    if let status = status { error += "\nStatus: \(status)" }
    
    error += "\n"
    
    return error
  }
}

extension GameServer
{
  enum Query : String
  {
    case UserConnect   = "uco"
    case UserCreate    = "ucr"
    case UserValidate  = "uvl"
    case UserInfo      = "uin"
    case DropUser      = "udr"
    case UpdateUser    = "uup"
    case ResetPassword = "pwr"
    case GetMatches    = "mat"
    case ILostTheGame  = "ilg"
    case CheckForEmail = "eex"
    case SendPassword  = "epw"
    case SendUsername  = "eun"
    case ReportError   = "err"
    
    var qArg : GameQuery.Args { return ["q" : self.rawValue] }
  }
  
  var time : Int?
  {
    var rval : Int?
    if case .Success(let data) = query(QueryKey.Time).execute().status {
      debug("time value returned: \(data?.time ?? -2)")
      rval = data?.time
    }
    debug("time function returning \(rval ?? -1)")
    return rval
  }
  
  func query(_ q:Query, args:GameQuery.Args? = nil) -> GameQuery
  {
    var gameArgs : GameQuery.Args = [ "q" : q.rawValue ]
    if let args = args {
      for (key,value) in args { gameArgs[key] = value }
    }
    return query("q", args:gameArgs)
  }
  
  func execute( _ q : Query,
                args : GameQuery.Args,
                requiredResponses : [String] = [],
                recognizedReturnCodes : [Int] = [],
                completion: @escaping (GameQuery)->() )
  {
    query(q, args: args).execute() {
      (query) in
      
      if query.status == nil
      {
        query.setQueryError("No status set by execute")
      }
      else if case .Success(let data) = query.status
      {
        for key in requiredResponses {
          if data?[key] == nil { query.addQueryError("Missing " + key + " in response") }
        }
      }
      else if case .QueryFailure(let rc,_) = query.status
      {
        if recognizedReturnCodes.contains(rc) == false
        {
          query.setQueryError("Unexpected Game Server Return Code: \(query.status!.failure)")
        }
      }
      
      completion(query)
    }
  }
  
  func login( username:String,
              password:String,
              completion:@escaping (GameQuery)->())
  {
    execute(
      .UserValidate,
      args : [
        QueryKey.Username: username,
        QueryKey.Password: password
      ],
      requiredResponses: [
        QueryKey.Userkey
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUsername,
        GameQuery.Status.IncorrectPassword
      ],
      completion: completion
    )
  }
  
  func login( userkey:String,
              completion:@escaping (GameQuery)->())
  {
    execute(
      .UserValidate,
      args : [
        QueryKey.Userkey : userkey
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey
      ],
      completion: completion
    )
  }
   
  func login( fbid:String,
              completion:@escaping (GameQuery)->())
  {
    execute(
      .UserValidate,
      args : [
        QueryKey.FBID : fbid
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidFBID
      ],
      completion: completion
    )
  }
  
  func requestNewAccount( username:String,
                          password:String,
                          alias:String? = nil,
                          email:String? = nil,
                          completion:@escaping (GameQuery)->() )
  {
    var args : GameQuery.Args = [
      QueryKey.Username: username,
      QueryKey.Password: password
    ]
    
    if let alias = alias, alias.count > 0 { args[QueryKey.Alias] = alias }
    if let email = email, email.count > 0 { args[QueryKey.Email] = email }
    
    execute(
      .UserCreate,
      args : args,
      requiredResponses: [
        QueryKey.Userkey
      ],
      recognizedReturnCodes: [
        GameQuery.Status.UserExists
      ],
      completion: completion
    )
  }
  
  func connectWithFacebook( _ fbid: String,
                            completion:@escaping (GameQuery)->() )
  {
    execute(
      .UserConnect,
      args: [QueryKey.FBID : fbid ],
      requiredResponses: [
        QueryKey.Userkey
      ],
      recognizedReturnCodes: [
        GameQuery.Status.FailedToCreateFBID
      ],
      completion: completion
    )
  }
  
  func dropUser( userkey:String,
                 username: Bool = false,
                 facebook: Bool = false,
                 notify: Bool = true,
                 completion: @escaping (GameQuery)->() )
  {
    guard username || facebook else { return }
    
    let scope = ( facebook ? ( username ? "FU" : "F" ) : "U" )
    
    var args: GameQuery.Args = [
      QueryKey.Userkey : userkey,
      QueryKey.Scope : scope
      ]
    
    if notify { args[QueryKey.Notify] = "1" }
    
    execute(
      .DropUser,
      args: args,
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey
      ],
      completion: completion
    )
  }
  
  func userInfo( userkey:String,
                 completion: @escaping (GameQuery)->() )
  {
    execute(
      .UserInfo,
      args: [ QueryKey.Userkey : userkey ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey
      ],
      completion: completion
    )
  }
  
  func updateAccountInfo( userkey:String,
                          password:String? = nil,
                          alias:String? = nil,
                          email:String? = nil,
                          completion:@escaping (GameQuery)->() )
  {
    var args : GameQuery.Args = [ QueryKey.Userkey: userkey ]
    
    if let password = password, !password.isEmpty { args[QueryKey.Password] = password }
    if let alias    = alias,    !alias.isEmpty    { args[QueryKey.Alias]    = alias    }
    if let email    = email,    !email.isEmpty    { args[QueryKey.Email]    = email    }
    
    execute(
      .UpdateUser,
      args : args,
      requiredResponses: [
        QueryKey.Updated
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey,
        GameQuery.Status.FailedToUpdateUser
      ],
      completion: completion
    )
  }
  
  func checkFor(email:String, completion:@escaping (Bool?,GameQuery)->())
  {
    let args : GameQuery.Args = [ QueryKey.Email : email ]
    
    var exists : Bool?
    
    query(.CheckForEmail, args: args).execute() {
      (query) in
      switch query.status
      {
      case .none:
        query.setQueryError("No status set by execute")
      case .Success:
        exists = true
      case .QueryFailure(GameQuery.Status.InvalidEmail, _):
        exists = false
      case .QueryFailure:
        query.setQueryError("Unexpected Game Server Return Code: \(query.status!.failure)")
      default: break
      }
     
      completion(exists,query)
    }
  }
  
  func sendUsernameEmail(email:String, completion:@escaping (GameQuery)->())
  {
    execute(
      .SendUsername,
      args : [
        QueryKey.Email: email,
        QueryKey.Salt: String(Defaults.resetSalt)
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidEmail
      ],
      completion: completion
    )
  }
  
  func sendPasswordResetEmail(username:String, completion:@escaping (GameQuery)->())
  {
    execute(
      .SendPassword,
      args : [
        QueryKey.Username: username,
        QueryKey.Salt: String(Defaults.resetSalt)
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUsername,
        GameQuery.Status.InvalidEmail
      ],
      completion: completion
    )
  }
  
  func resetPassword(username:String, password:String, resetCode:Int,
                     completion:@escaping (GameQuery)->())
  {
    execute(
      .ResetPassword,
      args: [
        QueryKey.Username  : username,
        QueryKey.Password  : password,
        QueryKey.ResetCode : String(resetCode)
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUsername,
        GameQuery.Status.FailedToUpdateUser
      ],
      completion: completion
    )
  }
  
  func lookupOpponents(userkey:String, completion:@escaping (GameQuery)->())
  {
    execute(
      .GetMatches,
      args: [
        QueryKey.Userkey : userkey
      ],
      requiredResponses: [
        QueryKey.Matches
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey
      ],
      completion: completion
    )
  }
  
  func updateLastLoss(userkey:String, completion:@escaping (GameQuery)->())
  {    
    execute(
      .ILostTheGame,
      args: [
        QueryKey.Userkey : userkey
      ],
      recognizedReturnCodes: [
        GameQuery.Status.FailedToUpdateUser
      ],
      completion: completion
    )
  }
  
  func sendErrorReport(_ message:[String])
  {
    sendErrorReport( message.joined(separator: "\n") )
  }
  
  func sendErrorReport(_ message:String)
  {
    query(Query.ReportError.rawValue, args:["details":message]).post { _ in }
  }
}
