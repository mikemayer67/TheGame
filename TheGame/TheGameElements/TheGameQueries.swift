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
  func requestNewAccount( username:String,
                          password:String,
                          alias:String? = nil,
                          email:String? = nil,
                          completion:@escaping (QueryResponse,String?)->() )
  {
    var args : GameQueryArgs = [.Username:username, .Password:password]
    
    if let alias = alias, alias.count > 0 { args[.Alias] = alias }
    if let email = email, email.count > 0 { args[.Email] = email }
    
    query(.User, action: .Create, gameArgs: args) { (response,url) in
      var rval  = response
      var error : String?
      
      if case .Success(let data) = response
      {
        if let userkey = data?.userkey
        {
          UserDefaults.standard.userkey  = userkey
          UserDefaults.standard.username = username
          UserDefaults.standard.alias    = alias
          
          let me = LocalPlayer(userkey, username: username, alias: alias, gameData: data)
          TheGame.shared.me = me
        }
        else
        {
          rval = .QueryFailure(0,nil)
          error = "No userkey returned"
        }
      }
        
      else if case .QueryFailure(let rc, _) = response
      {
        if rc != QueryResponse.UserExists
        { error = "Unexpected Game Server Return Code: \(response.failure)" }
      }
      
      completion(rval,error)
    }
  }
  
  func checkFor(email:String, completion:@escaping (QueryResponse,String?)->())
  {
    let args : GameQueryArgs = [ .Email : email ]
    
    query(.User, action: .Lookup, gameArgs: args) { (response,url) in
      var error : String?
      
      if case .QueryFailure(let rc, _) = response
      {
        if rc != QueryResponse.InvalidEmail
        { error = "Unexpected Game Server Return Code: \(response.failure)" }
      }
      
      completion(response,error)
    }
  }
  
  func sendUsernameEmail(email:String, completion:@escaping (Bool,QueryResponse,String?)->())
  {
    let args : GameQueryArgs = [ .Email : email, .Salt : String(UserDefaults.standard.resetSalt) ]
    
    query(.Email, action: .RetieveUsername, gameArgs: args) { (response,url) in
      var rval  = false
      var error : String?
      
      if case .Success = response { rval = true }
        
      else if case .QueryFailure(let rc, _) = response
      {
        if rc != QueryResponse.InvalidEmail
        {
          error = "Unexpected Game Server Return Code: \(response.failure)"
        }
      }
      
      completion(rval,response,error)
    }
  }
  
}
