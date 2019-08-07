//
//  SearchMenuTableViewModel.swift
//  Amby
//
//  Created by temma on 2017/08/01.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Model
import RxCocoa
import RxSwift

enum SearchMenuTableViewModelAction {
    case update
    case hide
}

final class SearchMenuTableViewModel {
    /// アクション通知用RX
    let rx_action = PublishSubject<SearchMenuTableViewModelAction>()

    /// ニュースセル高さ
    let newsCellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_NEWS_CELL_HEIGHT
    /// 通常セル高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    /// セクション高さ
    let sectionHeight = AppConst.FRONT_LAYER.TABLE_VIEW_SECTION_HEIGHT
    /// 表示セル数
    let cellNum = AppConst.FRONT_LAYER.SEARCH_TABLE_VIEW_ROW_NUM

    /// セクション
    let sectionItem: [String] = ["Google検索", "検索履歴", "閲覧履歴", "Top News"]
    /// オートコンプリートアイテム
    var suggestCellItem: [String] = []
    /// 検索履歴アイテム
    var searchHistoryCellItem: [SearchHistory] = []
    /// 閲覧履歴アイテム
    var commonHistoryCellItem: [CommonHistory] = []
    /// 記事アイテム
    var newsItem: [Article] = []
    /// 閲覧履歴読み込み数
    private let readCommonHistoryNum = SettingUseCase.s.commonHistorySaveCount
    /// 検索履歴読み込み数
    private let readSearchHistoryNum = SettingUseCase.s.searchHistorySaveCount
    /// サジェスト取得キュー
    private var requestSearchQueue = [String?]()
    /// サジェスト取得中フラグ
    private var isRequesting = false
    /// Observable自動解放
    let disposeBag = DisposeBag()

    init() {
        // サジェスト監視
        SuggestUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }

                switch action {
                case let .request(word):
                    // 閲覧履歴と検索履歴の検索
                    self.commonHistoryCellItem = SelectHistoryUseCase().exe(title: word, readNum: self.readCommonHistoryNum).objects(for: self.cellNum)
                    self.searchHistoryCellItem = SearchUseCase.s.select(title: word, readNum: self.readSearchHistoryNum).objects(for: self.cellNum)

                    // とりあえずここで画面更新
                    self.rx_action.onNext(.update)

                    // オートサジェスト
                    self.requestSearchQueue.append(word)
                    self.requestSearch()

                case let .update(suggest):
                    if let data = suggest.data, data.count > 0 {
                        // suggestあり
                        self.suggestCellItem = data.objects(for: self.cellNum)
                    } else {
                        self.suggestCellItem = []
                    }
                    self.isRequesting = false
                    // キューに積まれている場合は、再度検索にいく
                    if self.requestSearchQueue.count > 0 {
                        self.requestSearch()
                    } else {
                        self.rx_action.onNext(.update)
                    }
                }
            }
            .disposed(by: disposeBag)

        // 記事取得監視
        NewsUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .update(articles) = action else { return }
                if articles.count > 0 {
                    // exist article
                    self.newsItem = articles
                } else {
                    self.newsItem = []
                }

                // 画面更新
                self.rx_action.onNext(.update)
            }
            .disposed(by: disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        requestSearchQueue.removeAll()
    }

    /// 記事取得
    public func getArticle() {
        // 記事取得
        NewsUseCase.s.get()
    }

    /// 検索開始
    private func requestSearch() {
        if !isRequesting {
            isRequesting = true
            if let token = self.requestSearchQueue.removeFirst(), !token.isEmpty {
                if token.isUrl {
                    isRequesting = false
                } else {
                    SuggestUseCase.s.get(token: token)
                }
            } else {
                suggestCellItem = []
                commonHistoryCellItem = []
                searchHistoryCellItem = []
                isRequesting = false
                if requestSearchQueue.count > 0 {
                    requestSearch()
                } else {
                    rx_action.onNext(.hide)
                }
            }
        }
    }

    /// ロードリクエスト
    func loadRequest(url: String) {
        SearchUseCase.s.load(text: url)
    }
}
