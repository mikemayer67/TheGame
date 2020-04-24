//
//  GameQueryTypes.swift
//  TheGame
//
//  Created by Mike Mayer on 4/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

enum EmailStatus
{
  case NoEmail
  case HasValidatedEmail
  case HasUnvalidatedEmail
}

enum QueryAction : String
{
  case Time = "time"
  case User = "user"
}

enum QueryKey : String
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
  
typealias QueryArgs = [QueryKey:String]

enum QueryReturnCode : Int
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
      self = QueryReturnCode(rawValue: rc) ?? .InvalidCode
    } else {
      self = .MissingCode
    }
  }
}

struct QueryResponse
{
  typealias DataType = [String:Any]
  
  let rc   : QueryReturnCode
  let data : DataType?
  
  init(_ rc:Int)
  {
    self.rc = QueryReturnCode(rawValue: rc) ?? .InvalidCode
    self.data = nil
  }
  
  init(_ rc:QueryReturnCode = .FailedToConnect)
  {
    self.rc = rc
    self.data = nil
  }
  
  init(_ rawData:Data? )
  {
    if let rawData = rawData,
      let json = try? JSONSerialization.jsonObject(with: rawData, options: .allowFragments),
      let data = json as? DataType
    {
      if let rc = data["rc"] as? Int { self.rc = QueryReturnCode( rc ) }
      else                           { self.rc = .MissingCode          }
      
      self.data = data
    }
    else
    {
      self.rc = .FailedToConnect
      self.data = nil
    }
  }
  
  func getInt   (_ key:QueryKey) -> Int?    { data?[key.rawValue] as? Int    }
  func getDouble(_ key:QueryKey) -> Double? { data?[key.rawValue] as? Double }
  func getString(_ key:QueryKey) -> String? { data?[key.rawValue] as? String }
  func getAny   (_ key:QueryKey) -> Any?    { data?[key.rawValue]            }
  
  func getBool  (_ key:QueryKey) -> Bool?
  {
    guard let v = getInt(key) else { return nil }
    return ( v != 0 )
  }

  var success       : Bool { rc == .Success  }
  var serverFailure : Bool { rc.rawValue < 0 }
  var queryFailure  : Bool { rc.rawValue > 0 }
  
  var time        : Int?    { getInt(QueryKey.Time) }
  var userkey     : String? { getString(QueryKey.Userkey) }
  var lastLoss    : Int?    { getInt(QueryKey.Lastloss) }
  
  var hasUserkey  : Bool?   { getBool(QueryKey.Userkey) }
  var hasUsername : Bool?   { getBool(QueryKey.Username) }
  var hasFacebook : Bool?   { getBool(QueryKey.FBID) }
  
  var emailStatus : EmailStatus
  {
    guard let v = getBool(QueryKey.Email) else { return .NoEmail }
    return ( v ? .HasUnvalidatedEmail : .HasValidatedEmail )
  }
}

typealias QueryCompletion = (QueryResponse)->()
