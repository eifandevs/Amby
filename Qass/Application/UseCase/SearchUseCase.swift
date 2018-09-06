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
    func load(text: String) {
        let searchText = { () -> String in
            if text.isValidUrl {
                return text
            } else {
                // 検索ワードによる検索
                // 閲覧履歴を保存する
                SearchHistoryDataModel.s.store(text: text)

                let encodedText = "\(AppHttpConst.URL.SEARCH_PATH)\(text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)!)"
                return encodedText
            }
        }()
        ProgressUseCase.s.updateText(text: searchText)

        rx_searchUseCaseDidRequestLoad.onNext(searchText)
    }

    /// サークルメニューから検索開始押下
    func beginAtCircleMenu() {
        rx_searchUseCaseDidBeginSearching.onNext(true)
    }

    /// ヘッダーフィールドをタップして検索開始
    func beginAtHeader() {
        rx_searchUseCaseDidBeginSearching.onNext(false)
    }

    func delete() {
        SearchHistoryDataModel.s.delete()
    }

    func expireCheck() {
        SearchHistoryDataModel.s.expireCheck()
    }
}
