//
//  GameServer.swift
//  TheGame
//
//  Created by Mike Mayer on 4/26/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

// MARK:- Support Structures

enum QueryResponse
{
  case FailedToConnect
  case InvalidURI(URL)
  case Success(HashData?)
  case ServerFailure(Int)
  case QueryFailure(Int,HashData?)
  
  static let MissingCode           = -2
  static let InvalidCode           = -1
  static let Success               =  0
  
  init(_ rc:Int)
  {
    switch rc
    {
    case 0:     self = .Success(nil)
    case 1...:  self = .ServerFailure(rc)
    default:    self = .QueryFailure(rc,nil)
    }
  }
  
  init(_ rawData:Data )
  {
    let json = try? JSONSerialization.jsonObject(with: rawData, options: .allowFragments)
    let data = json as? HashData
    
    if let rc   = data?["rc"] as? Int
    {
      switch rc
      {
      case 0:     self = .Success(data)
      case 1...:  self = .QueryFailure(rc,data)
      default:    self = .ServerFailure(rc)
      }
    }
    else
    {
      self = .ServerFailure(QueryResponse.MissingCode)
    }
  }
  
  var rc : Int?
  {
    switch self
    {
    case .FailedToConnect:         return nil
    case .InvalidURI:              return nil
    case .Success:                 return QueryResponse.Success
    case .ServerFailure(let rc):   return rc
    case .QueryFailure(let rc, _): return rc
    }
  }
  
  var success : Bool { switch self { case .Success: return true; default: return false } }
}

typealias QueryArgs       = [String:String]
typealias QueryCompletion = (QueryResponse,URL)->()

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
        if response.statusCode == 200, let data = data {
          queryResponse = QueryResponse(data)
        }
        else
        {
          queryResponse = .InvalidURI(url)
        }
      }
      else
      {
        self.connected = false
        queryResponse = .FailedToConnect
      }
 
      DispatchQueue.main.async { completion(queryResponse,url) }
    }
    currentTask!.resume()
  }
  
  func query(_ page:String, args:QueryArgs? = nil) -> QueryResponse
  {
    guard let url = self.url(page, args:args) else { fatalError("Invalid URL") }
    
    guard let data = try? Data(contentsOf: url) else
    {
      self.connected = false
      return .FailedToConnect
    }
    
    self.connected = true
    return QueryResponse(data)
  }
  
  func post(_ page:String, args:QueryArgs, completion: @escaping QueryCompletion)
  {
    currentTask?.cancel()
    
    guard let url = self.url(page) else { fatalError("Invalid URL") }
    let request = NSMutableURLRequest(url:url)
    request.httpMethod = "POST"
    
    guard let data = try? JSONSerialization.data(withJSONObject: args, options: .prettyPrinted)
      else { completion(.InvalidURI(url),url); return  }
    
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
    request.httpBody = data
    
    currentTask = session.dataTask(with: request as URLRequest) { (data, response, err) in
      defer { self.currentTask = nil }
      
      var queryResponse : QueryResponse!
      
      if err == nil, let response = response as? HTTPURLResponse
      {
        self.connected = true
        if response.statusCode == 200, let data = data
        {
          queryResponse = QueryResponse(data)
        }
        else
        {
          queryResponse = .InvalidURI(url)
        }
      }
      else
      {
        self.connected = false
        queryResponse = .FailedToConnect
      }
      
      DispatchQueue.main.async { completion(queryResponse,url) }
    }
    currentTask!.resume()
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
    query("test") { (response,url) in completion( response.success ) }
  }
}

