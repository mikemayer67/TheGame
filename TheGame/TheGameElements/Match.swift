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
  
  init?(_ data:NSDictionary)
  {
    guard
      let matchID = data[QueryKey.MatchID] as? Int,
      let name    = data[QueryKey.Name] as? String,
      let start   = data[QueryKey.MatchStart] as? Double
    else { return nil }
    
    self.id    = matchID
    self.name  = name
    self.start = GameTime(networktime: start)
    
    self.fbid = data[QueryKey.FBID] as? String
    
    self.lastLoss = {
      guard let t = data[QueryKey.LastLoss] as? Double else { return nil }
      guard t > 0.0 else { return nil }
      return GameTime(networktime: t)
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
      guard let match = MatchData(matchData) else { return nil }
      _matches.append( match )
    }
  }
  
  func makeIterator() -> Array<MatchData>.Iterator
  {
    return _matches.makeIterator()
  }
}
