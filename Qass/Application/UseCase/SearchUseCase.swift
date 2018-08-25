//
//  SearchUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// 検索ユースケース
final class SearchUseCase {

    static let s = SearchUseCase()

    /// 検索開始通知用RX
    let rx_searchUseCaseDidBeginSearching = PublishSubject<Bool>()
    /// ロードリクエスト通知用RX
    let rx_searchUseCaseDidRequestLoad = PublishSubject<String>()

    private init() {}

    /// ロードリクエスト
    func load(url: String) {
        rx_searchUseCaseDidRequestLoad.onNext(url)
    }

    /// サークルメニューから検索開始押下
    func beginAtCircleMenu() {
        rx_searchUseCaseDidBeginSearching.onNext(true)
    }

    /// ヘッダーフィールドをタップして検索開始
    func beginAtHeader() {
        rx_searchUseCaseDidBeginSearching.onNext(false)
    }

}
