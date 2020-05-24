//
//  TheGameQueries.swift
//  TheGame
//
//  Created by Mike Mayer on 5/16/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

extension GameServer
{
  func requestNewAccount( username:String, password:String, alias:String? = nil, email:String? = nil,
                          failConnect:(()->())? = nil,
                          error:((_ message:String)->())? = nil,
                          success:(()->())? = nil,
                          exists:(()->())? = nil )
  {
    var args : GameQueryArgs = [.Username:username, .Password:password]
    
    if let alias = alias, alias.count > 0 { args[.Alias] = alias }
    if let email = email, email.count > 0 { args[.Email] = email }
    
    query(.User, action: .Create, gameArgs: args) { (response) in
            
      switch ( response.status, response.returnCode )
      {
      case (.FailedToConnect,_):   failConnect?()
      case (.InvalidURI,_):        error?(response.status.rawValue)
      case (.MissingCode,_):       error?(response.status.rawValue)
      case (.Success,.UserExists): exists?()
        
      case (.Success,.Success):
        if let userkey = response.userkey
        {
          UserDefaults.standard.userkey = userkey
          UserDefaults.standard.username = username
          UserDefaults.standard.alias = alias
          
          let me = LocalPlayer(userkey, username: username, alias: alias, gameData: response.data)
          TheGame.shared.me = me
          
          success?()
        }
        else
        {
          error?("no userkey returned")
        }
        
      default:
        if let  rc = response.rc { error?("Unexpected Game Server Return Code: \(rc)") }
        else                     { error?("Missing Response Code")                     }
      }
    }
  }
  
  func checkFor(email:String,
                failConnect:(()->())? = nil,
                error:((_ message:String)->())? = nil,
                completion:@escaping ((Bool)->()) )
  {
    let args : GameQueryArgs = [ .Email : email ]
    
    query(.User, action: .Lookup, gameArgs: args) { (response) in
      switch response.status
      {
      case .FailedToConnect: failConnect?()
      case .InvalidURI, .MissingCode: error?(response.status.rawValue)
        
      case .Success:
        switch response.returnCode
        {
        case .InvalidEmail: completion(false)
        case .Success:      completion(true)
        default:
          if let  rc = response.rc { error?("Unexpected Game Server Return Code: \(rc)") }
          else                     { error?("Missing Response Code")                     }
        }
      }
    }
  }
  
  func sendUsernameEmail(email:String,
                         failConnect:(()->())? = nil,
                         error:((_ message:String)->())? = nil,
                         completion:@escaping ((Bool)->()) )
  {
    let args : GameQueryArgs = [ .Email : email, .Salt : String(UserDefaults.standard.resetSalt) ]
    
    query(.Email, action: .RetieveUsername, gameArgs: args) { (response) in
      switch response.status
      {
      case .FailedToConnect: failConnect?()
      case .InvalidURI, .MissingCode: error?(response.status.rawValue)
        
      case .Success:
        switch response.returnCode
        {
        case .InvalidEmail: completion(false)
        case .Success:      completion(true)
        default:
          if let  rc = response.rc { error?("Unexpected Game Server Return Code: \(rc)") }
          else                     { error?("Missing Response Code")                     }
        }
      }
    }
  }
}
