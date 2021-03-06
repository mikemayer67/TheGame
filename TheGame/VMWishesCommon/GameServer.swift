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
  
  private var _clockOffset : TimeInterval? = nil
  var clockOffset : TimeInterval { _clockOffset ?? 0.0 }
  
  init()
  {
    guard let host = Bundle.main.object(forInfoDictionaryKey: "ServerHost") as? String
      else { fatalError("Missing ServerHost in info.plist") }
    
    self.host = host
    
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    config.timeoutIntervalForRequest = 5
    session = URLSession(configuration: config)
        
//    connected = testConnection()
  }

  func query(_ page:String, args:GameQuery.Args? = nil, post:GameQuery.Args? = nil) -> GameQuery
  {
    return GameQuery(self, page, args: args, post:post)
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
  
  func testConnection( completion: @escaping (Bool)->())
  {
    query(QueryKey.Time).execute() {
      (query) in
      switch query.status
      {
      case .Success(let data):
        self.connected = true
        if self._clockOffset == nil, let serverTime = data?.time
        {
          let now = Date().timeIntervalSince1970 as TimeInterval
          self._clockOffset = TimeInterval(serverTime) - now
        }
      default:
        self.connected = false
      }
      completion( self.connected )
    }
  }
}

