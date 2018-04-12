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

    let sectionItem: [String] = ["Google検索", "検索履歴", "閲覧履歴"]
    var googleSearchCellItem: [String] = []
    var searchHistoryCellItem: [SearchHistory] = []
    var historyCellItem: [CommonHistory] = []
    private let readCommonHistoryNum: Int = UserDefaults.standard.integer(forKey: AppConst.KEY_COMMON_HISTORY_SAVE_COUNT)
    private let readSearchHistoryNum: Int = UserDefaults.standard.integer(forKey: AppConst.KEY_SEARCH_HISTORY_SAVE_COUNT)
    private var requestSearchQueue = [String?]()
    private var isRequesting = false
    /// Observable自動解放
    let disposeBag = DisposeBag()
    var existDisplayData: Bool {
        return googleSearchCellItem.count > 0 || historyCellItem.count > 0 || searchHistoryCellItem.count > 0
    }

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
                        self.requestSearchQueue.append(token)
                        self.requestSearch()
                    }
                }
                log.eventOut(chain: "rx_operationDataModelDidChange")
            }
            .disposed(by: disposeBag)

        // サジェスト検索監視
        SuggestDataModel.s.rx_suggestDataModelDidUpdate
            .observeOn(MainScheduler.asyncInstance)
            .map { [weak self] (suggest) -> Suggest in
                guard let `self` = self else { return suggest }
                self.historyCellItem = CommonHistoryDataModel.s.select(title: suggest.token, readNum: self.readCommonHistoryNum).objects(for: 4)
                self.searchHistoryCellItem = SearchHistoryDataModel.s.select(title: suggest.token, readNum: self.readSearchHistoryNum).objects(for: 4)
                return suggest
            }
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
                if self.requestSearchQueue.count > 0 {
                    self.requestSearch()
                } else {
                    self.rx_searchMenuViewWillUpdateLayout.onNext(())
                }

                log.eventOut(chain: "rx_suggestDataModelDidUpdate")
            }
            .disposed(by: disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        requestSearchQueue.removeAll()
        NotificationCenter.default.removeObserver(self)
    }

    private func requestSearch() {
        if !isRequesting {
            isRequesting = true
            if let token = self.requestSearchQueue.removeFirst(), !token.isEmpty {
                SuggestDataModel.s.fetch(token: token)
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
