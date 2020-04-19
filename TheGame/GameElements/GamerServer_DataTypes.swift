//
//  GamerServer_DataTypes.swift
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

enum GameServerResponse
{
  case FailedToConnect
  case FailedToLogin
  case ServerError
  
  case UserCreated(LocalPlayer)      // userkey
  case UserAlreadyExists(EmailStatus)
  case UserKeyValidated(Int,String?) // username, alias, last loss
  case InvalidUserKey
  
  case NotYetImplemented // @@@ delete after all dev complete
}

typealias QueryArgs = [String:String]

class QueryResponse
{
  enum Code : Int
  {
    case InvalidCode = -3
    case MissingCode = -2
    case FailedToConnect = -1
    case Success = 0
    case UserExists = 1
    case FailedToCreateUser = 2
    case InvalidUserkey = 3
    case FailedToValidateUser = 4
    case FailedToUpdateUser = 5
    case FailedToDropUser = 6
    case NothingToDrop = 7
    
    init(_ rc:Int?)
    {
      if let rc = rc {
        self = Code(rawValue: rc) ?? .InvalidCode
      } else {
        self = .MissingCode
      }
    }
  }
  
  typealias DataType = [String:Any]
  
  var rc   : Code
  var data : DataType?
  
  init(_ rc:Int = -1)
  {
    self.rc = Code(rawValue: rc) ?? Code.InvalidCode
    self.data = nil
  }
  
  init(_ rawData:Data? )
  {
    if let rawData = rawData,
      let json = try? JSONSerialization.jsonObject(with: rawData, options: .allowFragments),
      let data = json as? DataType
    {
      self.rc   = Code( data["rc"] as? Int )
      self.data = data
    }
    else
    {
      self.rc = .FailedToConnect
      self.data = nil
    }
  }
}

typealias QueryCompletion = (QueryResponse)->()
