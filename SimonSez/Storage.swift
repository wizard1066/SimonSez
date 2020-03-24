//
//  Storage.swift
//  coduku
//
//  Created by localadmin on 23.03.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit

struct rex {
  var id: String!
  var token: String!
}

var tokens = [rex]()

class Storage: NSObject {
  
  override init() {
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(onUbiquitousKeyValueStoreDidChangeExternally(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    cleanUp()
  }
  
  @objc func onUbiquitousKeyValueStoreDidChangeExternally(notification:Notification)
  {
      tokens.removeAll()
      let newCodes = getCodes()
      for (kvalue,value) in newCodes! {
        let record = rex(id: kvalue, token: (value as! String))
        tokens.append(record)
      }
      playPublisher.send(tokens)
  }

  func saveCode(randomCode:String, token:String) {
    var codes = NSUbiquitousKeyValueStore.default.dictionary(forKey: "codes")
    let dayOfTheWeek = String(Date().dayNumberOfWeek()!)
    if codes != nil {
      for code in codes! {
        if String(code.key.last!) != dayOfTheWeek {
          codes?.removeValue(forKey: code.key)
        }
      }
      codes?[randomCode] = token
      NSUbiquitousKeyValueStore.default.set(codes, forKey: "codes")
    } else {
      var codes = [String:String]()
      codes[randomCode] = token
      NSUbiquitousKeyValueStore.default.set(codes, forKey: "codes")
    }
  }
  
  func getCodes() -> [String:Any]? {
    let codes = NSUbiquitousKeyValueStore.default.dictionary(forKey: "codes")
    if codes != nil {
      return codes
    } else {
      return nil
    }
  }
  
  func deleteCode(randomCode:String) {
    var codes = NSUbiquitousKeyValueStore.default.dictionary(forKey: "codes")
    if codes != nil {
      codes?.removeValue(forKey: randomCode)
      NSUbiquitousKeyValueStore.default.set(codes, forKey: "codes")
    }
  }
  
  func refreshCodes() {
    tokens.removeAll()
    let newCodes = getCodes()
    if newCodes != nil {
      for (kvalue,value) in newCodes! {
        let record = rex(id: kvalue, token: (value as! String))
        tokens.append(record)
      }
      playPublisher.send(tokens)
    }
  }
  
  func cleanUp() {
    NSUbiquitousKeyValueStore.default.set([:], forKey: "codes")
  }
  
}
