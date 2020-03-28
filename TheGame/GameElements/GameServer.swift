//
//  GameServer.swift
//  TheGame
//
//  Created by Mike Mayer on 3/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation
import FacebookLogin

fileprivate let SERVER_HOST = "https://localhost/thegame"

enum UserEmailStatus
{
  case NoEmail
  case HasValidatedEmail
  case HasUnvalidatedEmail
}

enum GameServerResponse
{
  case FailedToConnect
  case FailedToLogin
  case ConnectionExists
  case ServerError
  case UserCreated(String)      // userkey
  case UserAlreadyExists(UserEmailStatus)
  case UserKeyValidated(Int,String?) // username, alias, last loss
  case InvalidUserKey
  
  case NotYetImplemented // @@@ delete after all dev complete
}

class GameServer
{
  static let shared = GameServer()
  
  var username : String?
  { didSet { UserDefaults.standard.set(username, forKey: "username") } }
  
  var password : String?
  { didSet { UserDefaults.standard.set(password, forKey: "password") } }
  
  var userkey  : String?
  { didSet { UserDefaults.standard.set(userkey, forKey: "userkey") }  }

  var fbToken  : AccessToken?
  
  var session     : URLSession
  var currentTask : URLSessionDataTask?
  
  var hasConnection = false
  {
    didSet {
      if hasConnection != oldValue { RootViewController.shared.update() }
    }
  }
  
  var hasLogin : Bool
  {
    get { return ((userkey != nil) || (fbToken != nil)) }
  }
    
  private init()
  {
    fbToken = AccessToken.current
    
    username = UserDefaults.standard.string(forKey: "username")
    password = UserDefaults.standard.string(forKey: "password")
    userkey  = UserDefaults.standard.string(forKey: "userkey")
    
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    session = URLSession(configuration: config)
  }
  
  typealias QueryReturnData = [String:Any]
  typealias QueryCompletion = (Int,QueryReturnData)->()
      
  func query(_ page:String, args:Dictionary<String,String>? = nil,  completion: @escaping QueryCompletion)
  {
    currentTask?.cancel()
    
    guard var uc = URLComponents(string:"\(SERVER_HOST)/\(page)") else { fatalError("Invalid URL") }
    
    var queryItems = [URLQueryItem]()
    if let args = args{
      for (name,value) in args {
        queryItems.append(URLQueryItem(name: name, value: value))
      }
    }
    uc.queryItems = queryItems
    
    guard let url = URL(string: uc.url!.absoluteString) else { fatalError("Invalid URL") }
    
    currentTask = session.dataTask(with: url) { (data, response, err) in
      defer { self.currentTask = nil }
        
      debug(url)
      debug("data:",data,"\nerr:",err,"\nresponse",response)
      if err == nil,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200,
        let data = data,
        let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
        let queryResponse = jsonResponse as? [String:Any],
        let rc = queryResponse["rc"] as? Int
      {
        DispatchQueue.main.async { completion(rc, queryResponse) }
      }
      else
      {
        DispatchQueue.main.async {
          self.hasConnection = false
          completion(-1,QueryReturnData())
        }
      }
    }
    currentTask!.resume()
  }
}

extension GameServer  // connection
{
  func testConnection( completion: @escaping (GameServerResponse)->())
  {
    query("test")
    {
      (rc,_) in
      if rc == 0 { self.hasConnection = true;  completion(.ConnectionExists) }
      else       { self.hasConnection = false; completion(.FailedToConnect)  }
    }
  }
  
  func testLogin( completion: @escaping (GameServerResponse)->())
  {
    if let fbid = self.fbToken
    {
      debug("Add FB confirmation")
    }
    else if let uk = self.userkey, !uk.isEmpty
    {
      query("user", args: ["action":"info", "userkey":uk])
      {
        (rc, reply) in
        switch rc {
        case 0:
          let lastLoss = reply["last_lost"] as? Int ?? 0
          let alias    = reply["name"]      as? String
          debug("Add user info to Player")
          completion(.UserKeyValidated(lastLoss, alias))
        case 3: // unknown userkey
          self.userkey = nil
          completion(.InvalidUserKey)
        case -1:
          completion(.FailedToConnect)
        default:
          // We got a response, but it's not consistent with the API
          completion(.ServerError)
        }
      }
    }
    else
    {
      completion(.FailedToLogin)
    }
  }
  
}

extension GameServer  // Username/Password accounts
{
  func createAccount(username:String, password:String, alias:String, email:String,
                     completion: @escaping (GameServerResponse)->())
  {
    var queryItems : [String:String] = [
      "action"   : "create",
      "username" : username ,
      "password" : password
    ]
    if !alias.isEmpty { queryItems["alias"] = alias }
    if !email.isEmpty { queryItems["email"] = email }
    
    query("user", args: queryItems)
    {
      (rc, reply) in
      switch rc
      {
      case 0: // successfully created a new user (but only if userkey was returned)
        if let userkey = reply["userkey"] as? String
        {
          self.username = username
          self.password = password
          self.userkey  = userkey
          completion(.UserCreated(userkey))
        }
        
      case 1: // user exists (determine if they specified an email and whether or not it's validated)
        var emailStatus : UserEmailStatus = .NoEmail
        if let email = reply["email"] as? Int
        {
          emailStatus = ( email == 1 ? .HasValidatedEmail : .HasUnvalidatedEmail )
        }
        completion(.UserAlreadyExists(emailStatus))
        
      default:
        // We got a response, but it's not consistent with the API
        completion(.ServerError)
      }
    }
  }
}


