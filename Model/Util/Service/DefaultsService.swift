//
//  Defaults.swift
//  Defaults
//
//  Created by Luca D'Alberti on 9/27/16.
//  Copyright © 2016 dalu93. All rights reserved.
//
import Foundation

public struct DefaultKey<T>: Equatable {
    public var name: String
    public var defaultValue: T
    public init(name: String, defaultValue: T) {
        self.name = name
        self.defaultValue = defaultValue
    }
}

public func ==<T>(lhs: DefaultKey<T>, rhs: DefaultKey<T>) -> Bool {
    return lhs.name == rhs.name
}
