//
//  NewsUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// 通知ユースケース
public final class NewsUseCase {
    public static let s = NewsUseCase()

    /// プログレス更新通知用RX
    public let rx_newsUseCaseDidUpdate = ArticleDataModel.s.rx_articleDataModelDidUpdate
        .flatMap { articles -> Observable<[Article]> in
            return Observable.just(articles)
        }

    private init() {}

    public func get() {
        ArticleDataModel.s.get()
    }
}
