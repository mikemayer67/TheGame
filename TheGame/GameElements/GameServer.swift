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

protocol GameServerListener
{
  
}

class GameServer
{
  static let shared = GameServer()
  
  var username : String?
  { didSet { UserDefaults.standard.set(username, forKey: "username") } }
  
  var password : String?
  { didSet { UserDefaults.standard.set(password, forKey: "password") } }
  
  var userkey  : String?
  { didSet { UserDefaults.standard.set(userkey, forKey: "userkey") } }

  var fbToken  : AccessToken?
  
  var session     : URLSession
  var currentTask : URLSessionDataTask?
    
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
  
  func hasConnection() -> Bool
  {
    return ((userkey != nil) || (fbToken != nil))
  }
}

extension GameServer  // Username/Password accounts
{
  func createAccount(username:String, password:String, alias:String, email:String,
                     completion: @escaping (GameServerResponse)->())
  {
    currentTask?.cancel()
    
    // setup the API call to attempt creating a new user
    
    var queryItems = [
      URLQueryItem(name: "action",   value: "create"),
      URLQueryItem(name: "username", value: username),
      URLQueryItem(name: "password", value: password)
    ]
    if alias.isEmpty == false {
      queryItems.append(URLQueryItem(name: "alias", value: alias))
    }
    if email.isEmpty == false {
      queryItems.append(URLQueryItem(name: "email", value: email))
    }
    
    guard var uc = URLComponents(string:"\(SERVER_HOST)/user") else { fatalError("Invalid URL") }
    uc.queryItems = queryItems
    
    guard let url = URL(string: uc.url!.absoluteString) else { fatalError("Invalid URL") }

    // attempt to create a new user by calling the GameServer user API
    
    currentTask = session.dataTask(with: url) { (data, response, err) in
      defer { self.currentTask = nil }
      
      var completionResponse : GameServerResponse = .FailedToConnect  // catchall if anything went wrong with the API call
      
      if err == nil,
        let data = data,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200,
        let reply = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
        let rc = reply["rc"] as? Int
      {
        switch rc
        {
        case 0: // successfully created a new user (but only if userkey was returned)
          completionResponse = .ServerError // (until proven otherwise)
          if let userkey = reply["userkey"] as? String
          {
            self.username = username
            self.password = password
            self.userkey  = userkey
            completionResponse = .UserCreated(userkey)
          }
          
        case 1: // user exists (determine if they specified an email and whether or not it's validated)
          var emailStatus : UserEmailStatus = .NoEmail
          if let email = reply["email"] as? Int
          {
            emailStatus = ( email == 1 ? .HasValidatedEmail : .HasUnvalidatedEmail )
          }
          completionResponse = .UserAlreadyExists(emailStatus)
          
        default:
          // We got a response, but it's not consistent with the API
          completionResponse = .ServerError
        }
      }
      
      DispatchQueue.main.async { completion(completionResponse) }
    }
    currentTask!.resume()
  }
}


