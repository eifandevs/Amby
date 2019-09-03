//
//  WebCacheHandlerUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import WebKit

public enum WebCacheHandlerUseCaseAction {
    case deleteCookies
    case deleteCaches
}

public final class WebCacheHandlerUseCase {
    public static let s = WebCacheHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<WebCacheHandlerUseCaseAction>()

    private var tabDataModel: TabDataModelProtocol!

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
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
