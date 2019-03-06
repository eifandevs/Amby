//
//  WebCacheUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import WebKit

public enum WebCacheUseCaseAction {
    case deleteCookies
    case deleteCaches
}

public final class WebCacheUseCase {
    public static let s = WebCacheUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<WebCacheUseCaseAction>()

    private var pageHistoryDataModel: PageHistoryDataModelProtocol!

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        pageHistoryDataModel = PageHistoryDataModel.s
    }

    public func cacheConfiguration() -> WKWebViewConfiguration {
        let dataStore = pageHistoryDataModel.isPrivate ? WKWebsiteDataStore.nonPersistent() : WKWebsiteDataStore.default()
        log.debug("set data store mode: \(dataStore.isPersistent ? "persistent" : "nonpersistent")")
        return CacheService.cacheConfiguration(dataStore: dataStore)
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
