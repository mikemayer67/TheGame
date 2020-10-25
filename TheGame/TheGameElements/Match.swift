//
//  Match.swift
//  TheGame
//
//  Created by Mike Mayer on 10/15/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

struct MatchData
{
  let id : Int
  let name : String
  let fbid : String?
  let start : GameTime
  let lastLoss : GameTime?
  
  init?(_ data:HashData)
  {
    guard
      let matchID = data.matchID,
      let name    = data.name,
      let start   = data.matchStart
    else { return nil }
    
    self.id    = matchID
    self.name  = name
    self.start = GameTime(networktime: start)
    
    self.fbid = data.fbid
    
    self.lastLoss = {
      guard let t = data.lastLoss else { return nil }
      guard t > 0 else { return nil }
      return GameTime(networktime: Double(t))
    }()
  }
}

class MatchSet : Sequence
{
  private var _matches = Array<MatchData>()
  
  init?(_ data:HashData?)
  {
    guard
      let data = data,
      let matches = data[QueryKey.Matches] as? [NSDictionary]
    else { return nil }
    
    for matchData in matches
    {
      guard let hd = matchData as? HashData else { return nil }
      guard let match = MatchData(hd) else { return nil }
      _matches.append( match )
    }
  }
  
  func makeIterator() -> Array<MatchData>.Iterator
  {
    return _matches.makeIterator()
  }
}
