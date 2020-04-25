//
//  GameServer.swift
//  TheGame
//
//  Created by Mike Mayer on 3/1/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

// MARK:- Query Support Structures

fileprivate let SERVER_HOST = "https://localhost/thegame"

class GameServer
{
  var session     : URLSession
  var currentTask : URLSessionDataTask?
  
  var connected = false
  
  init()
  {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    session = URLSession(configuration: config)
    
    connected = self.testConnection()
  }
    
  func query(_ page:QueryPage, action: QueryAction? = nil, args:QueryArgs? = nil,  completion: @escaping QueryCompletion)
  {
    currentTask?.cancel()
    
    guard let url = GameServer.url(page, action:action, args:args) else { fatalError("Invalid URL") }
        
    currentTask = session.dataTask(with: url) { (data, response, err) in
      defer { self.currentTask = nil }
      
      var queryResponse = QueryResponse()
      
      if err == nil, let response = response as? HTTPURLResponse
      {
        if response.statusCode == 200 { queryResponse = QueryResponse( data ) }
        else                          { queryResponse = QueryResponse(.InvalidURI) }
      }
      
      self.connected = queryResponse.rc != .FailedToConnect
      
      DispatchQueue.main.async { completion(queryResponse) }
    }
    currentTask!.resume()
  }
  
  func query(_ page:QueryPage, action:QueryAction? = nil, args:QueryArgs? = nil) -> QueryResponse
  {
    guard let url = GameServer.url(page, action:action, args:args) else { fatalError("Invalid URL") }
    
    let data = try? Data(contentsOf: url)
    
    self.connected = data != nil
    
    return QueryResponse(data)
  }
  
  static func url(_ page:QueryPage, action: QueryAction? = nil, args:QueryArgs? = nil) -> URL?
  {
    guard var uc = URLComponents(string:"\(SERVER_HOST)/\(page.rawValue)") else { return nil }
    
    var queryItems = [URLQueryItem]()
    if let action = action
    {
      queryItems.append(URLQueryItem(name:"action", value:action.rawValue))
    }
    if let args = args{
      for (key,value) in args {
        queryItems.append(URLQueryItem(name: key.rawValue, value: value))
      }
    }
    if queryItems.count > 0 { uc.queryItems = queryItems }
    
    return URL(string: uc.url!.absoluteString)
  }

  var time : Int? { query(.Time).time }
  
  func testConnection() -> Bool
  {
    self.connected = query(.Time).success
    return self.connected
  }
  
  func testConnection( completion: @escaping (Bool)->())
  {
    query(.Time) { response in
      completion( response.success )
    }
  }
}

