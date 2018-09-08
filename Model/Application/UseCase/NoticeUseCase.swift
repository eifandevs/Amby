//
//  NoticeUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// 通知ユースケース
public final class NoticeUseCase {
    public static let s = NoticeUseCase()

    /// プログレス更新通知用RX
    public let rx_noticeUseCaseDidInvoke = Observable
        .merge([
            FormDataModel.s.rx_formDataModelDidNotice,
            FavoriteDataModel.s.rx_favoriteDataModelDidNotice
        ])
        .flatMap { message -> Observable<String> in
            return Observable.just(message)
        }

    private init() {}
}
