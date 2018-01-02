//
//  SearchMenuTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/08/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol SearchMenuTableViewModelDelegate: class {
    func searchMenuViewWillUpdateLayout()
    func searchMenuViewWillHide()
}

class SearchMenuTableViewModel {
    let sectionItem: [String] = ["Google検索", "検索履歴", "閲覧履歴"]
    weak var delegate: SearchMenuTableViewModelDelegate?
    var googleSearchCellItem: [String] = []
    var searchHistoryCellItem: [SearchHistory] = []
    var historyCellItem: [CommonHistory] = []
    private let readCommonHistoryNum: Int = UserDefaults.standard.integer(forKey: AppConst.KEY_HISTORY_SAVE_TERM)
    private let readSearchHistoryNum: Int = UserDefaults.standard.integer(forKey: AppConst.KEY_SEARCH_HISTORY_SAVE_TERM)
    private var requestSearchQueue = [String?]()
    private var isRequesting = false
    var existDisplayData: Bool {
        return googleSearchCellItem.count > 0 || historyCellItem.count > 0 || searchHistoryCellItem.count > 0
    }

    init() {
        // webview検索
        // オペレーション監視
        NotificationCenter.default.addObserver(forName: .operationDataModelDidChange, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[SearchMenuTableView Event]: operationDataModelDidChange")

            let operation = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OPERATION] as! UserOperation
            let token = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OBJECT] as! String

            if operation == .suggest && !token.isEmpty {
                self.requestSearchQueue.append(token)
                self.requestSearch()
            }
        }
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
                        self.delegate?.searchMenuViewWillUpdateLayout()
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
                    self.delegate?.searchMenuViewWillHide()
                }
            }
        }
    }

    /// ユーザーアクション実行
    func executeOperationDataModel(operation: UserOperation, url: String) {
        OperationDataModel.s.executeOperation(operation: operation, object: url)
    }
}
