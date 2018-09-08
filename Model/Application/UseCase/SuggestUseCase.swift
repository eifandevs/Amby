//
//  SuggestUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// サジェストユースケース
public final class SuggestUseCase {
    public static let s = SuggestUseCase()

    /// サジェストリクエスト通知用RX
    public let rx_suggestUseCaseDidRequestSuggest = PublishSubject<String>()

    /// サジェスト通知用RX
    public let rx_suggestUseCaseDidUpdate = SuggestDataModel.s.rx_suggestDataModelDidUpdate
        .flatMap { suggest -> Observable<Suggest> in
            return Observable.just(suggest)
        }

    private init() {}

    /// サジェストリクエスト
    public func suggest(word: String) {
        rx_suggestUseCaseDidRequestSuggest.onNext(word)
    }

    /// 取得
    public func get(token: String) {
        SuggestDataModel.s.get(token: token)
    }
}
