//
//  SearchMenuTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/08/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SearchMenuTableViewModel {
    /// 画面更新通知用RX
    let rx_searchMenuViewWillUpdateLayout = PublishSubject<Void>()
    /// 画面無効化通知用RX
    let rx_searchMenuViewWillHide = PublishSubject<Void>()
    
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
        NotificationCenter.default.rx.notification(.operationDataModelDidChange, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[SearchMenuTableViewModel Event]: operationDataModelDidChange")
                if let notification = notification.element {
                    let operation = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OPERATION] as! UserOperation
                    
                    if operation == .suggest {
                        let token = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OBJECT] as! String
                        self.requestSearchQueue.append(token)
                        self.requestSearch()
                    }
                }
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
                self.historyCellItem = CommonHistoryDataModel.s.select(title: token, readNum: self.readCommonHistoryNum).objects(for: 4)
                self.searchHistoryCellItem = SearchHistoryDataModel.s.select(title: token, readNum: self.readSearchHistoryNum).objects(for: 4)
                SuggestDataModel.fetch(token: token, completion: { (suggest) in
                    if let suggest = suggest, suggest.data.count > 0 {
                        // suggestあり
                        self.googleSearchCellItem = suggest.data.objects(for: 4)
                    }
                    self.isRequesting = false
                    if self.requestSearchQueue.count > 0 {
                        self.requestSearch()
                    } else {
                        self.rx_searchMenuViewWillUpdateLayout.onNext(())
                    }
                })
            } else {
                self.googleSearchCellItem = []
                self.historyCellItem = []
                self.searchHistoryCellItem = []
                isRequesting = false
                if self.requestSearchQueue.count > 0 {
                    self.requestSearch()
                } else {
                    self.rx_searchMenuViewWillHide.onNext(())
                }
            }
        }
    }

    /// ユーザーアクション実行
    func executeOperationDataModel(operation: UserOperation, url: String) {
        OperationDataModel.s.executeOperation(operation: operation, object: url)
    }
}
