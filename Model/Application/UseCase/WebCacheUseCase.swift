//
//  WebCacheUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import WebKit

public final class WebCacheUseCase {
    public static let s = WebCacheUseCase()

    private init() {}

    public func cacheConfiguration() -> WKWebViewConfiguration {
        return CacheService.cacheConfiguration()
    }

    /// Cacheの削除
    public func deleteCaches() {
        CacheService.deleteCaches()
    }

    /// Cookieの削除
    public func deleteCookies() {
        CacheService.deleteCookies()
    }
}
