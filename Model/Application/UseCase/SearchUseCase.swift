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

public enum SearchUseCaseAction {
    case searchAtMenu
    case serachAtHeader
    case load(text: String)
}

/// 検索ユースケース
public final class SearchUseCase {
    public static let s = SearchUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<SearchUseCaseAction>()

    private init() {}

    /// ロードリクエスト
    public func load(text: String) {
        let searchText = { () -> String in
            if text.isValidUrl {
                return text
            } else {
                // 検索ワードによる検索
                // 閲覧履歴を保存する
                SearchHistoryDataModel.s.store(text: text)

                let encodedText = "\(ModelConst.URL.SEARCH_PATH)\(text)"
                return encodedText
            }
        }()
        ProgressUseCase.s.updateText(text: searchText)

        rx_action.onNext(.load(text: searchText))
    }

    /// サークルメニューから検索開始押下
    public func beginAtCircleMenu() {
        rx_action.onNext(.searchAtMenu)
    }

    /// ヘッダーフィールドをタップして検索開始
    public func beginAtHeader() {
        rx_action.onNext(.serachAtHeader)
    }

    public func delete() {
        SearchHistoryDataModel.s.delete()
    }

    /// 検索履歴の検索
    /// 検索ワードと検索件数を指定する
    /// 指定ワードを含むかどうか
    public func select(title: String, readNum: Int) -> [SearchHistory] {
        return SearchHistoryDataModel.s.select(title: title, readNum: readNum)
    }

    public func expireCheck() {
        SearchHistoryDataModel.s.expireCheck()
    }
}
