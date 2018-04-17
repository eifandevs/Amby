//
//  SearchMenuTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/08/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class SearchMenuTableViewModel {
    /// 画面更新通知用RX
    let rx_searchMenuViewWillUpdateLayout = PublishSubject<()>()
    /// 画面無効化通知用RX
    let rx_searchMenuViewWillHide = PublishSubject<()>()

    let sectionItem: [String] = ["Google検索", "検索履歴", "閲覧履歴", "Top News"]
    var googleSearchCellItem: [String] = []
    var searchHistoryCellItem: [SearchHistory] = []
    var historyCellItem: [CommonHistory] = []
    var newsItem: [Article] = []
    private let readCommonHistoryNum: Int = UserDefaults.standard.integer(forKey: AppConst.KEY_COMMON_HISTORY_SAVE_COUNT)
    private let readSearchHistoryNum: Int = UserDefaults.standard.integer(forKey: AppConst.KEY_SEARCH_HISTORY_SAVE_COUNT)
    private var requestSearchQueue = [String?]()
    private var isRequesting = false
    /// Observable自動解放
    let disposeBag = DisposeBag()

    init() {
        // webview検索
        // オペレーション監視
        OperationDataModel.s.rx_operationDataModelDidChange
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_operationDataModelDidChange")
                guard let `self` = self else { return }
                if let object = object.element {
                    if object.operation == .suggest {
                        let token = object.object as! String
                        // 閲覧履歴と検索履歴の検索
                        self.historyCellItem = CommonHistoryDataModel.s.select(title: token, readNum: self.readCommonHistoryNum).objects(for: 4)
                        self.searchHistoryCellItem = SearchHistoryDataModel.s.select(title: token, readNum: self.readSearchHistoryNum).objects(for: 4)

                        // とりあえずここで画面更新
                        self.rx_searchMenuViewWillUpdateLayout.onNext(())

                        // オートサジェスト
                        self.requestSearchQueue.append(token)
                        self.requestSearch()
                    }
                }
                log.eventOut(chain: "rx_operationDataModelDidChange")
            }
            .disposed(by: disposeBag)

        // サジェスト検索監視
        SuggestDataModel.s.rx_suggestDataModelDidUpdate
            .subscribe { [weak self] suggest in
                log.eventIn(chain: "rx_suggestDataModelDidUpdate")

                guard let `self` = self else { return }
                if let suggest = suggest.element, let data = suggest.data, data.count > 0 {
                    // suggestあり
                    self.googleSearchCellItem = data.objects(for: 4)
                } else {
                    self.googleSearchCellItem = []
                }
                self.isRequesting = false
                // キューに積まれている場合は、再度検索にいく
                if self.requestSearchQueue.count > 0 {
                    self.requestSearch()
                } else {
                    self.rx_searchMenuViewWillUpdateLayout.onNext(())
                }

                log.eventOut(chain: "rx_suggestDataModelDidUpdate")
            }
            .disposed(by: disposeBag)

        // 記事取得監視
        ArticleDataModel.s.rx_articleDataModelDidUpdate
            .subscribe { [weak self] element in
                log.eventIn(chain: "rx_articleDataModelDidUpdate")

                guard let `self` = self else { return }
                if let articles = element.element, articles.count > 0 {
                    // suggestあり
                    self.newsItem = articles
                } else {
                    self.newsItem = []
                }

                log.eventOut(chain: "rx_articleDataModelDidUpdate")
            }
            .disposed(by: disposeBag)

        // 記事取得
        ArticleDataModel.s.fetch()
    }

    deinit {
        log.debug("deinit called.")
        requestSearchQueue.removeAll()
        NotificationCenter.default.removeObserver(self)
    }

    /// 検索開始
    private func requestSearch() {
        if !isRequesting {
            isRequesting = true
            if let token = self.requestSearchQueue.removeFirst(), !token.isEmpty {
                if token.isUrl {
                    isRequesting = false
                } else {
                    SuggestDataModel.s.fetch(token: token)
                }
            } else {
                googleSearchCellItem = []
                historyCellItem = []
                searchHistoryCellItem = []
                isRequesting = false
                if requestSearchQueue.count > 0 {
                    requestSearch()
                } else {
                    rx_searchMenuViewWillHide.onNext(())
                }
            }
        }
    }

    /// ユーザーアクション実行
    func executeOperationDataModel(operation: UserOperation, url: String) {
        OperationDataModel.s.executeOperation(operation: operation, object: url)
    }
}
