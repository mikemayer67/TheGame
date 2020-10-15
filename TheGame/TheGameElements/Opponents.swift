//
//  Opponents.swift
//  TheGame
//
//  Created by Mike Mayer on 10/13/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class Opponents : Sequence
{
  private(set) var opponents = Array<Opponent>()
  
  private var xref = Dictionary<Int,Opponent>()
  
  subscript(index:Int) -> Opponent? { return opponents[safe:index] }
  
  func makeIterator() -> Array<Opponent>.Iterator {
    return opponents.makeIterator()
  }
  
  func enumerated() -> EnumeratedSequence<Array<Opponent>>
  {
    return opponents.enumerated()
  }
  
  var isEmpty : Bool  { return opponents.isEmpty }
  var count   : Int   { return opponents.count   }
  
  func find(matchID:Int) -> Opponent? { return xref[matchID] }
  
  func add(_ opponent:Opponent)
  {
    guard xref[opponent.matchID] == nil else { return }
    opponents.append(opponent)
    xref[opponent.matchID] = opponent
  }
  
  func drop(matchID:Int)
  {
    opponents.removeAll(where: { $0.matchID == matchID } )
    xref.removeValue(forKey:matchID)
  }
  
  func dropAll()
  {
    opponents.removeAll()
    xref.removeAll()
  }
  
  func sort() { opponents.sort() }
    
  var order : Dictionary<Int,Int> {
    var rval = Dictionary<Int,Int>()
    for (rank, opponent) in opponents.enumerated() { rval[opponent.matchID] = rank }
    return rval
  }
  
  func hasLoss(after t:GameTime?) -> Bool
  {
    for opponent in opponents {
      if opponent.lost(after: t) { return true }
    }
    return false
  }
}
