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
  static let DevToken   = "dev_token"
  static let Dropped    = "dropped"
  static let Email      = "email"
  static let EmailVal   = "email_validation"
  static let FBID       = "fbid"
  static let LastLoss   = "last_loss"
  static let MatchID    = "match_id"
  static let MatchStart = "match_start"
  static let Matches    = "matches"
  static let Name       = "name"
  static let Notify     = "notify"
  static let ResetCode  = "reset"
  static let Salt       = "salt"
  static let Scope      = "scope"
  static let Time       = "time"
  static let Updated    = "updated"
  static let Userid     = "userid"
  static let Userkey    = "userkey"
  static let Validated  = "validated"
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
  var name        : String? { getString(QueryKey.Name) }
  var email       : String? { getString(QueryKey.Email) }
  var lastLoss    : Int?    { getInt(QueryKey.LastLoss) }
  
  var emailStatus : EmailStatus
  {
    return EmailStatus( getBool(QueryKey.Email) )
  }
}

extension GameQuery.Status
{
  static let Failed                =  1
  static let UserExists            =  2
  static let InvalidUserkey        =  3
  static let InvalidFBID           =  4
  static let FailedToCreateFBID    =  5
  static let FailedToCreatePlayer  =  6
  static let FailedToUpdatePlayer  =  7
  static let NoValidatedEmail      =  8
  static let InvalidEmail          =  9
  static let EmailFailure          = 10
  static let InvalidOpponent       = 11
  static let NotificationFailure   = 12
  static let CurlFailure           = 13
  static let ApnsFailure           = 14
  
  static let strings : [Int:String] =
  [
    MissingData          : "Missing Data",
    MissingCode          : "No Return Code",
    InvalidCode          : "Invalid Code",
    Success              : "Success",
    UserExists           : "User Exists",
    InvalidUserkey       : "Invalid Userkey",
    InvalidFBID          : "Invalid Facebook ID",
    FailedToCreateFBID   : "Failed To Create FBID",
    FailedToCreatePlayer : "Failed To Create New Player",
    FailedToUpdatePlayer : "Failed To Update Player Info",
    NoValidatedEmail     : "NoValidated Email",
    InvalidEmail         : "Invalid Email",
    EmailFailure         : "Game server failed to send email",
    NotificationFailure  : "Notification Failure",
    CurlFailure          : "Invalid curl Command",
    ApnsFailure          : "Failed To Complete APNS Transaction",
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
    case CheckForEmail    = "eex"
    case SendRecoveryCode = "erc"
    case ReportError      = "err"
    case SetDevToken      = "gdt"
    case DropOpponent     = "gem"
    case ILostTheGame     = "ilg"
    case GetMatches       = "mat"
    case PokeOpponent     = "pok"
    case UserCreate       = "ucr"
    case DropUser         = "udr"
    case UserFBCreate     = "ufb"
    case UserFBDrop       = "ufd"
    case UserInfo         = "uin"
    case UpdateUser       = "uup"
    case UserValidate     = "uvl"
    
    var qArg : GameQuery.Args { return ["q" : self.rawValue] }
  }
  
  var time : Int?
  {
    var rval : Int?
    if case .Success(let data) = query(QueryKey.Time).execute().status {
      rval = data?.time
    }
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
   
  /**
   Validates that a user with the specified Facebook ID exists on the game server.
   
   Note that unlike the otehr login methods, this one has the side effect of updating
   the database.  Specifically, it updates the Facebook username if it has changed
   since the last time the id was used.
   
   - Parameer fbid: Facebook ID
   - Parameter name: The name associated with fbid (*based on Facebook Graph API*)
   - Parameter completion: completion handler invoked after query has completed
   */
  func login( fbid:String,
              name:String,
              completion:@escaping (GameQuery)->())
  {
    execute(
      .UserValidate,
      args : [
        QueryKey.FBID : fbid,
        QueryKey.Name : name
      ],
      requiredResponses: [
        QueryKey.Userkey
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidFBID
      ],
      completion: completion
    )
  }
  
  func requestNewPlayer( name:String,
                         email:String? = nil,
                         completion:@escaping (GameQuery)->() )
  {
    var args : GameQuery.Args = [
      QueryKey.Name: name,
    ]
    
    if let email = email, email.count > 0 { args[QueryKey.Email] = email }
    
    execute(
      .UserCreate,
      args : args,
      requiredResponses: [
        QueryKey.Userkey
      ],
      completion: completion
    )
  }
  
  func createFacebookUser( fbid: String, name: String,
                           completion:@escaping (GameQuery)->() )
  {
    execute(
      .UserFBCreate,
      args: [
        QueryKey.FBID : fbid,
        QueryKey.Name : name
      ],
      requiredResponses: [
        QueryKey.Userkey
      ],
      recognizedReturnCodes: [
        GameQuery.Status.FailedToCreatePlayer,
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
  
  func dropFacebookUser( userkey:String,
                         completion: @escaping (GameQuery)->()  )
  {
    execute(
      .UserFBDrop,
      args : [
        QueryKey.Userkey : userkey
      ],
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
  
  func updatePlayerInfo( userkey:String,
                         name:String? = nil,
                         email:String? = nil,
                         completion:@escaping (GameQuery)->() )
  {
    var args : GameQuery.Args = [ QueryKey.Userkey: userkey ]
    
    if let name  = name,  !name.isEmpty  { args[QueryKey.Name]  = name  }
    if let email = email, !email.isEmpty { args[QueryKey.Email] = email }
    
    execute(
      .UpdateUser,
      args : args,
      requiredResponses: [
        QueryKey.Updated
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey,
        GameQuery.Status.FailedToUpdatePlayer
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
        GameQuery.Status.FailedToUpdatePlayer,
        GameQuery.Status.InvalidUserkey
      ],
      completion: completion
    )
  }
  
  func pokeOpponent(userkey:String, matchID:Int, completion:@escaping (GameQuery)->())
  {
    execute(
      .PokeOpponent,
      args: [
        QueryKey.Userkey : userkey,
        QueryKey.MatchID : String(matchID)
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey,
        GameQuery.Status.InvalidOpponent,
        GameQuery.Status.NotificationFailure,
        GameQuery.Status.CurlFailure,
        GameQuery.Status.ApnsFailure,
        ],
      completion: completion
    )
  }
  
  func dropOpponent(userkey:String, matchID:Int, notify:Bool, completion:@escaping (GameQuery)->())
  {
    execute(
      .DropOpponent,
      args: [
        QueryKey.Userkey : userkey,
        QueryKey.MatchID : String(matchID),
        QueryKey.Notify  : (notify ? "1" : "0")
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey,
        GameQuery.Status.InvalidOpponent,
        GameQuery.Status.CurlFailure,
        GameQuery.Status.ApnsFailure,
        ],
      completion: completion
    )
  }
  
  func clearDeviceToken(userkey:String, completion:@escaping (GameQuery)->())
  {
    setDeviceToken(userkey:userkey, deviceToken:nil, completion:completion)
  }
  
  func setDeviceToken(userkey:String, deviceToken:String?, completion:@escaping (GameQuery)->())
  {
    var args : GameQuery.Args = [ QueryKey.Userkey : userkey ]
    if deviceToken != nil { args[QueryKey.DevToken] = deviceToken }
    
    execute(
      .SetDevToken,
      args: args,
      recognizedReturnCodes: [
        GameQuery.Status.InvalidUserkey,
        GameQuery.Status.Failed
        ],
      completion: completion
    )
  }
  
  func sendRecoveryCode(email:String, salt:String? = nil, completion:@escaping (GameQuery)->())
  {
    let salt = salt ?? String(Defaults.resetSalt)
    
    execute(
      .SendRecoveryCode,
      args: [
        QueryKey.Email : email,
        QueryKey.Salt : salt,
      ],
      recognizedReturnCodes: [
        GameQuery.Status.InvalidEmail,
        GameQuery.Status.EmailFailure,
      ],
      completion: completion)
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
