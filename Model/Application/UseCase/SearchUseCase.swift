//
//  SearchUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import CommonUtil
import Entity
import Foundation
import RxCocoa
import RxSwift

public enum SearchUseCaseAction {
    case searchAtMenu
    case searchAtHeader
    case load(text: String)
}

/// 検索ユースケース
public final class SearchUseCase {
    public static let s = SearchUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<SearchUseCaseAction>()

    /// models
    private var searchHistoryDataModel: SearchHistoryDataModelProtocol!
    private var pageHistoryDataModel: PageHistoryDataModelProtocol!

    private init() {
        setupProtocolImpl()
    }

    /// プロトコル実装
    private func setupProtocolImpl() {
        searchHistoryDataModel = SearchHistoryDataModel.s
        pageHistoryDataModel = PageHistoryDataModel.s
    }

    /// ロードリクエスト
    public func load(text: String) {
        let searchText = { () -> String in
            if text.isValidUrl {
                return text
            } else {
                // 検索ワードによる検索
                // 閲覧履歴を保存する
                // プライベートモードの場合は保存しない
                if pageHistoryDataModel.isPrivate {
                    log.debug("search history will not insert. ")
                } else {
                    searchHistoryDataModel.store(text: text)
                }

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
        rx_action.onNext(.searchAtHeader)
    }

    public func delete() {
        searchHistoryDataModel.delete()
    }

    /// 検索履歴の検索
    /// 検索ワードと検索件数を指定する
    /// 指定ワードを含むかどうか
    public func select(title: String, readNum: Int) -> [SearchHistory] {
        return searchHistoryDataModel.select(title: title, readNum: readNum)
    }

    public func expireCheck() {
        searchHistoryDataModel.expireCheck()
    }
}
