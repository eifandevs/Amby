//
//  LocalStorageTargetType.swift
//  Amby
//
//  Created by tenma on 2018/06/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

public protocol LocalStorageTargetType {
    /// The target's base
    var base: String { get }

    /// The target's base `URL`.
    var url: URL { get }

    /// path
    var path: String { get }

    /// absolutePath
    var absolutePath: String { get }
}
