//
//  GameQuery.swift
//  TheGame
//
//  Created by Mike Mayer on 5/24/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class GameQuery
{
  typealias Args       = [String:String]
  typealias Completion = (GameQuery)->()
  
  enum Status
  {
    case FailedToConnect
    case InvalidURL(URL)
    case Success(HashData?)
    case ServerFailure(Int)
    case QueryFailure(Int,HashData?)
    case QueryError(String)
    
    static let MissingData = -3
    static let MissingCode = -2
    static let InvalidCode = -1
    static let Success     =  0
    
    init(_ rc:Int?, data:HashData? = nil)
    {
      if rc == nil    { self = Status.ServerFailure(Status.MissingCode) }
      else if rc! < 0 { self = Status.ServerFailure(rc!) }
      else if rc! > 0 { self = Status.QueryFailure(rc!,data) }
      else            { self = Status.Success(data) }
    }
    
    init(_ rawData:Data )
    {
      let json = try? JSONSerialization.jsonObject(with: rawData, options: .allowFragments)
      let data = json as? HashData
      self.init( data?["rc"] as? Int, data:data)
    }
    
    init(error:String)
    {
      self = .QueryError(error)
    }
    
    var rc : Int?
    {
      switch self
      {
      case .QueryError:              return nil
      case .FailedToConnect:         return nil
      case .InvalidURL:              return nil
      case .Success:                 return Status.Success
      case .ServerFailure(let rc):   return rc
      case .QueryFailure(let rc, _): return rc
      }
    }
    
    var success : Bool { if case .Success = self { return true } else { return false } }
  }
  
  let server : GameServer?
  let page : String
  let args : Args?
  let post : Args?
  
  private(set) var url    : URL!
  private(set) var status : Status?
  
  init(_ server:GameServer? = nil, _ page:String, args:Args? = nil, post:Args? = nil)
  {
    self.server = server
    self.page   = page
    self.args   = args
    self.post   = post
  }
  
  func setQueryError(_ error:String)
  {
    status = .QueryError(error)
  }
  
  func addQueryError(_ error:String)
  {
    if case .QueryError(let curError) = status {
      status = .QueryError(curError + ", " + error)
    } else {
      status = .QueryError(error)
    }
  }
  
  func execute(server:GameServer? = nil, completion:@escaping Completion)
  {
    guard let server = server ?? self.server else { fatalError("no server set") }
    
    guard self.post == nil else
    {
      post(server: server, completion: completion)
      return
    }
    
    url = url(server:server, args:args)
        
    let request = NSMutableURLRequest(url:url)
    request.httpMethod = "GET"
    
    server.start(request as URLRequest) { (status) in
      self.status = status
      DispatchQueue.main.async { completion(self) }
    }
  }
  
  func post(server:GameServer? = nil, completion:@escaping Completion)
  {
    guard let server = server ?? self.server else { fatalError("no server set") }
    
    guard let post = self.post else
    {
      execute(server: server, completion: completion)
      return
    }
    
    url = url(server: server, args: self.args)
    
    let request = NSMutableURLRequest(url:url)
    request.httpMethod = "POST"
    
    guard let data =
      try? JSONSerialization.data(withJSONObject: post, options: .prettyPrinted)
      else { fatalError("Args cannot be converted to JSON") }
    
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
    request.httpBody = data
    
    debug("server.start:: url=\(url)")
    
    server.start(request as URLRequest) { (status) in
      debug("server.start completion")
      self.status = status
      DispatchQueue.main.async { completion(self) }
    }
  }
  
  private func url(server:GameServer, args:Args? = nil) -> URL
  {
    guard var uc = URLComponents(string:"\(server.host)/\(self.page)")
      else { fatalError("Failed to create URL components") }
    
    if let args = args, args.count > 0 {
      var q = [URLQueryItem]()
      for (key,value) in args { q.append(URLQueryItem(name:key, value:value)) }
      uc.queryItems = q
    }
    
    guard let rval = URL(string:uc.url!.absoluteString)
      else { fatalError("Failed to convert URL components to URL") }
    
    return rval
  }
  
}
