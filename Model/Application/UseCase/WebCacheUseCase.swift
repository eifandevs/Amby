//
//  WebCacheUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import WebKit
import RxCocoa
import RxSwift

public enum WebCacheUseCaseAction {
    case deleteCookies
    case deleteCaches
}

public final class WebCacheUseCase {
    public static let s = WebCacheUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<WebCacheUseCaseAction>()
    
    private init() {}

    public func cacheConfiguration() -> WKWebViewConfiguration {
        return CacheService.cacheConfiguration()
    }

    /// Cacheの削除
    public func deleteCaches() {
        CacheService.deleteCaches()
        rx_action.onNext(.deleteCaches)
    }

    /// Cookieの削除
    public func deleteCookies() {
        CacheService.deleteCookies()
        rx_action.onNext(.deleteCookies)
    }
}
