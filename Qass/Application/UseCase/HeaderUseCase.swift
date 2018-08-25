//
//  HeaderUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ヘッダーユースケース
final class HeaderUseCase {

    static let s = HeaderUseCase()

    /// プログレス更新通知用RX
    let rx_HeaderUseCaseDidChangeProgress = Observable
        .merge([
            HeaderViewDataModel.s.rx_headerViewDataModelDidUpdateProgress,
            NotificationCenter.default.rx.notification(.UIApplicationDidBecomeActive, object: nil).flatMap { _ in Observable.just(0) }
            ])
        .flatMap { progress -> Observable<CGFloat> in
            return Observable.just(progress)
    }

    /// テキストフィールド更新通知用RX
    let rx_HeaderUseCaseDidChangeField = HeaderViewDataModel.s.rx_headerViewDataModelDidUpdateText
        .flatMap { text -> Observable<String> in
            return Observable.just(text)
    }
}
