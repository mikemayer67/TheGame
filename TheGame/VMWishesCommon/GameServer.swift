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
  enum Status : String
  {
    case Success          = "Success"
    case FailedToConnect  = "Failed To Connect"
    case InvalidURI       = "Invalid URI"
    case MissingCode      = "Missing Return Code"
  }
  
  let rc     : Int?
  let status : Status
  let data   : HashData?
  
  init()
  {
    self.rc = nil
    self.data = nil
    self.status = .FailedToConnect
  }
  
  init(_ status : Status = .FailedToConnect )
  {
    self.rc     = nil
    self.data   = nil
    self.status = status
  }
  
  init(_ rawData:Data )
  {
    let json =
      try? JSONSerialization.jsonObject(with: rawData, options: .allowFragments)
      
    self.data = json as? HashData
    if let rc = data?["rc"] as? Int
    {
      self.status = .Success
      self.rc     = rc
    }
    else
    {
      self.status = .MissingCode
      self.rc     = nil
    }
  }
  
  var success       : Bool { (rc ?? -1) == 0 }
  var serverFailure : Bool { (rc ?? -1)  < 0 }
  var queryFailure  : Bool { (rc ?? -1)  > 0 }
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
      
      var queryResponse : QueryResponse!
      
      if err == nil, let response = response as? HTTPURLResponse
      {
        self.connected = true
        if response.statusCode == 200, let data = data { queryResponse = QueryResponse(data)        }
        else                                           { queryResponse = QueryResponse(.InvalidURI) }
      }
      else
      {
        self.connected = false
        queryResponse = QueryResponse(.FailedToConnect)
      }
 
      DispatchQueue.main.async { completion(queryResponse) }
    }
    currentTask!.resume()
  }
  
  func query(_ page:String, args:QueryArgs? = nil) -> QueryResponse
  {
    guard let url = self.url(page, args:args) else { fatalError("Invalid URL") }
    
    guard let data = try? Data(contentsOf: url) else
    {
      self.connected = false
      return QueryResponse(.FailedToConnect)
    }
    
    self.connected = true
    return QueryResponse(data)
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

