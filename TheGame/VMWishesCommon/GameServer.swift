//
//  GameServer.swift
//  TheGame
//
//  Created by Mike Mayer on 4/26/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class GameServer
{
  let host        : String
  var session     : URLSession
  
  var connected = false
  
  init()
  {
    guard let host = Bundle.main.object(forInfoDictionaryKey: "ServerHost") as? String
      else { fatalError("Missing ServerHost in info.plist") }
    
    self.host = host
    
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    session = URLSession(configuration: config)
    
    connected = testConnection()
  }

  func query(_ page:String, args:GameQuery.Args? = nil) -> GameQuery
  {
    return GameQuery(self, page, args: args)
  }
  
  func start(_ request:URLRequest,
             completion: @escaping (GameQuery.Status) -> Void )
  {
    let task = session.dataTask(with: request )
    {
      (data, response, err) in
      
      var status : GameQuery.Status!
      if err == nil, let response = response as? HTTPURLResponse
      {
        if response.statusCode == 200, let data = data {
          status = GameQuery.Status(data)
        } else {
          status = GameQuery.Status.InvalidURL(request.url!)
        }
      }
      else
      {
        self.connected = false
        status = GameQuery.Status.FailedToConnect
      }
      completion(status)
    }
    
    task.resume()
  }
  
  func testConnection() -> Bool
  {
    self.connected = query("test").execute().status?.success ?? false
    return self.connected
  }
  
  func testConnection( completion: @escaping (Bool)->())
  {
    query("test").execute() {
      (query) in
      self.connected = query.status?.success ?? false
      completion( self.connected )
    }
  }
}

