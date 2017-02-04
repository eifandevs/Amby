//
//  logger.swift
//  sample
//
//  Created by tenma on 2017/01/30.
//  Copyright © 2017年 tenma. All rights reserved.
//

import Foundation

func debugLog(_ obj: Any?,
              function: String = #function,
              line: Int = #line) {
    #if DEBUG
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        let now = Date()
        let date = formatter.string(from: now)
        
        if let obj = obj {
            print("[\(date)_\(function)_\(line)]: \(obj)")
        } else {
            print("[\(date)_\(function)_\(line)]")
        }
    #endif
}
