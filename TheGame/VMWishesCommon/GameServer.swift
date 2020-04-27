//
//  GameServer.swift
//  TheGame
//
//  Created by Mike Mayer on 4/26/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

// MARK:- Support Structures

class QueryResponse
{  
  let rc   : Int?
  let data : HashData?
  
  init(_ rc:Int? = nil)
  {
    self.rc = rc
    self.data = nil
  }
  
  init(_ rawData:Data )
  {
    let json =
      try? JSONSerialization.jsonObject(with: rawData, options: .allowFragments)
      
    self.data = json as? HashData
    self.rc   = data?["rc"] as? Int
  }
  
  var success       : Bool { rc == 0 }
  var serverFailure : Bool { (rc ?? -1) < 0 }
  var queryFailure  : Bool { (rc ?? -1) > 0 }
}

typealias QueryArgs       = [String:String]
typealias QueryCompletion = (QueryResponse)->()

// Mark :- Server

class GameServer
{
  let host        : String
  var session     : URLSession
  var currentTask : URLSessionDataTask?
  
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
    
  func query(_ page:String, args:QueryArgs? = nil, completion: @escaping QueryCompletion)
  {
    currentTask?.cancel()
    
    guard let url = self.url(page, args:args) else { fatalError("Invalid URL") }
        
    currentTask = session.dataTask(with: url) { (data, response, err) in
      defer { self.currentTask = nil }
      
      var queryResponse = QueryResponse()
      
      if err == nil,
        let response = response as? HTTPURLResponse,
        response.statusCode == 200,
        let data = data
      {
        queryResponse = QueryResponse( data )
      }
      
      self.connected = queryResponse.rc != nil
      
      DispatchQueue.main.async { completion(queryResponse) }
    }
    currentTask!.resume()
  }
  
  func query(_ page:String, args:QueryArgs? = nil) -> QueryResponse
  {
    guard let url = self.url(page, args:args) else { fatalError("Invalid URL") }

    var queryResponse = QueryResponse()

    if let data = try? Data(contentsOf: url)
    {
      queryResponse = QueryResponse(data)
    }

    self.connected = queryResponse.rc != nil
    
    return queryResponse
  }
  
  func url(_ page:String, args:QueryArgs? = nil) -> URL?
  {
    guard var uc = URLComponents(string:"\(host)/\(page)") else { return nil }
    
    var queryItems = [URLQueryItem]()
    if let args = args{
      for (key,value) in args {
        queryItems.append(URLQueryItem(name: key, value: value))
      }
    }
    if queryItems.count > 0 { uc.queryItems = queryItems }
    
    return URL(string: uc.url!.absoluteString)
  }
  
  func testConnection() -> Bool
  {
    self.connected = query("test").success
    return self.connected
  }
  
  func testConnection( completion: @escaping (Bool)->())
  {
    query("test") { response in
      completion( response.success )
    }
  }
}

