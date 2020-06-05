//
//  LocalPlayer_TheGame.swift
//  TheGame
//
//  Created by Mike Mayer on 5/29/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

extension LocalPlayer
{
  static func connect(username:String, password:String, completion: @escaping (GameQuery,LocalPlayer?)->())
  {
    TheGame.server.login(username: username, password: password) {
      (query) in
      
      var me : LocalPlayer? = nil
            
      if case .Success(let data) = query.status,
        let userkey = data?.userkey // should never fail (login query checks this)
      {
        me = LocalPlayer(userkey, username: username, alias: data?.alias, data: data)
      }
      
      completion(query,me)
    }
  }
}
