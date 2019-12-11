//
//  DispatchQueue+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/03/10.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    class func mainSyncSafe(execute work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }

    class func mainSyncSafe<T>(execute work: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try work()
        } else {
            return try DispatchQueue.main.sync(execute: work)
        }
    }
}
