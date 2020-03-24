//
//  crypto.swift
//  coduku
//
//  Created by localadmin on 23.03.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit

class Crypto: NSObject {
  func genCode() -> String? {
    let random = Int.random(in: 4096 ..< 65535)
    let digit = String(format:"%02X", random) + String(Date().dayNumberOfWeek()!)
    return digit
  }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
