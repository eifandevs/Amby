//
//  Cache.swift
//  Qass
//
//  Created by tenma on 2018/06/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

enum Cache {
    case pageHistory
    case commonHistory(resource: String?)
    case searchHistory(resource: String?)
    case thumbnails(additionalPath: String?, resource: String?)
    case database
}

extension Cache: LocalStorageTargetType {
    /// The target's base
    var base: String { return DeviceConst.CACHES_PATH }
    
    /// The target's base `URL`.
    var url: URL { return URL(fileURLWithPath: self.base + self.path) }
    
    /// absolute path
    var absolutePath: String { return self.base + self.path }
    
    /// path
    var path: String {
        switch self {
        case .pageHistory:
            return "/page_history.dat"
        case let .commonHistory(resource):
            let path: String = {
                if let resource = resource {
                    return "/common_history/\(resource)"
                } else {
                    return "/common_history"
                }
            }()
            
            return path
        case .searchHistory:
            return "/search_history"
        case let .thumbnails(additionalPath, resource):
            let path: String = {
                if let additionalPath = additionalPath {
                    return "/thumbnails/\(additionalPath)"
                } else {
                    return "/thumbnails"
                }
            }()
            
            let resourcePath: String = {
                if let resource = resource {
                    return "\(path)/\(resource)"
                } else {
                    return path
                }
            }()
            return resourcePath
        case .database:
            return "/database"
        }
    }
}
