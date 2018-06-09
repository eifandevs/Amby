//
//  Cache.swift
//  Qass
//
//  Created by tenma on 2018/06/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

enum Cache {
    case eachHistory
    case commonHistory
    case searchHistory
    case thumbnails(folder: String)
    case database
}

extension Cache: LocalStorageTargetType {
    /// The target's base
    var base: String {
        switch self {
        case let .thumbnails(folder):
            return DeviceConst.CACHES_PATH + "/\(folder)"
        default:
            return DeviceConst.CACHES_PATH
        }
    }
    
    /// The target's base `URL`.
    var url: URL { return URL(fileURLWithPath: self.base + self.path) }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .eachHistory:
            return "/each_history.dat"
        case .commonHistory:
            return "/common_history"
        case .searchHistory:
            return "/search_history"
        case .thumbnails:
            return "/thumbnails"
        case .database:
            return "/database"
        }
    }
}
