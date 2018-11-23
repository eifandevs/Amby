//
//  CacheUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/27.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// キャッシュユースケース
public final class CacheUseCase {
    /// クッキー削除通知用RX
    let rx_cacheUseCaseDidDeleteCookies = PublishSubject<()>()
    /// キャッシュ削除通知用RX
    let rx_cacheUseCaseDidDeleteCaches = PublishSubject<()>()

    public static let s = CacheUseCase()

    private init() {}

    public func deleteCookies() {
        CacheService.deleteCookies()
        rx_cacheUseCaseDidDeleteCookies.onNext(())
    }

    /// キャッシュ削除
    public func deleteCaches() {
        CacheService.deleteCaches()
        rx_cacheUseCaseDidDeleteCaches.onNext(())
    }
}
