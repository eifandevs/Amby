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
final class SuggestUseCase {
    static let s = SuggestUseCase()

    /// サジェストリクエスト通知用RX
    let rx_suggestUseCaseDidRequestSuggest = PublishSubject<String>()

    private init() {}

    /// サジェストリクエスト
    func suggest(word: String) {
        rx_suggestUseCaseDidRequestSuggest.onNext(word)
    }
}
