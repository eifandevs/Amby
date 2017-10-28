//
//  CacheHelper.swift
//  Qas
//
//  Created by temma on 2017/07/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import WebKit

class CacheHelper {
    // クッキーの共有
    static let processPool = WKProcessPool()
    
    static func cacheConfiguration(isPrivate: Bool) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = processPool
        // Cookie, Cache, その他Webデータを端末内に残す
        configuration.websiteDataStore = isPrivate ? WKWebsiteDataStore.nonPersistent() : WKWebsiteDataStore.default()
        configuration.allowsPictureInPictureMediaPlayback = true
        return configuration
    }
    
    /// Cacheの削除
    static func deleteCaches() {
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: [
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeOfflineWebApplicationCache,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeWebSQLDatabases,
            WKWebsiteDataTypeIndexedDBDatabases
        ], modifiedSince: dateFrom) {}
    }
    
    /// Cookieの削除
    static func deleteCookies() {
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeCookies], modifiedSince: dateFrom) {}
    }
}
