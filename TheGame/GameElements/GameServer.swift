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
    
  func query(_ action:QueryAction, args:QueryArgs? = nil,  completion: @escaping QueryCompletion)
  {
    currentTask?.cancel()
    
    guard let url = GameServer.url(action, args:args) else { fatalError("Invalid URL") }
    
    currentTask = session.dataTask(with: url) { (data, response, err) in
      defer { self.currentTask = nil }
      
      var queryResponse = QueryResponse()
      
      debug(url)
      debug("data:",data,"\nerr:",err,"\nresponse",response)
      if err == nil,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200
      {
        queryResponse = QueryResponse( data )
      }
      
      if queryResponse.rc == .FailedToConnect { self.connected = false }
      
      DispatchQueue.main.async { completion(queryResponse) }
    }
    currentTask!.resume()
  }
  
  func query(_ action:QueryAction, args:QueryArgs? = nil) -> QueryResponse
  {
    guard let url = GameServer.url(action, args:args) else { fatalError("Invalid URL") }
    
    let data = try? Data(contentsOf: url)
    
    return QueryResponse(data)
  }
  
  static func url(_ action:QueryAction, args:QueryArgs? = nil) -> URL?
  {
    guard var uc = URLComponents(string:"\(SERVER_HOST)/\(action.rawValue)") else { return nil }
    
    var queryItems = [URLQueryItem]()
    if let args = args{
      for (key,value) in args {
        queryItems.append(URLQueryItem(name: key.rawValue, value: value))
      }
    }
    uc.queryItems = queryItems
    
    return URL(string: uc.url!.absoluteString)
  }

  var time : Int? { query(.Time).time }
  
  func testConnection() -> Bool {  return query(.Time).success  }
  
  func testConnection( completion: @escaping (Bool)->())
  {
    query(.Time) { response in completion( response.success ) }
  }
}

