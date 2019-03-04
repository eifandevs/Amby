//
//  CacheService.swift
//  Model
//
//  Created by tenma on 2018/09/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import WebKit

class CacheService {
    // クッキーの共有
    static let processPool = WKProcessPool()

    static func cacheConfiguration(dataStore: WKWebsiteDataStore) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = processPool
        // Cookie, Cache, その他Webデータを端末内に残す
        configuration.websiteDataStore = dataStore
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = true
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
