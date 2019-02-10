//
//  Data+Extension.swift
//  Qas
//
//  Created by temma on 2017/09/28.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

public extension Data {
    public init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }

    public func toArray<T>(type _: T.Type) -> [T] {
        return withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count / MemoryLayout<T>.stride))
        }
    }
}
