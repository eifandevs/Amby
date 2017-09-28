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
    var searchHistoryCellItem: [SearchHistoryItem] = []
    var historyCellItem: [CommonHistoryItem] = []
    private let readCommonHistoryNum: Int = 31
    private let readSearchHistoryNum: Int = 62
    private var requestSearchQueue = [String?]()
    private var isRequesting = false
    var existDisplayData: Bool {
        return googleSearchCellItem.count > 0 || historyCellItem.count > 0 || searchHistoryCellItem.count > 0
    }

    init() {
        // webview検索
        NotificationCenter.default.addObserver(forName: .searchMenuTableViewModelWillUpdateSearchToken, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[SearchMenuTableView Event]: searchMenuTableViewModelWillUpdateSearchToken")
            let token = notification.object != nil ? (notification.object as! [String: String])["token"] : nil
            self.requestSearchQueue.append(token)
            self.requestSearch()
        }
    }

    deinit {
        requestSearchQueue.removeAll()
        NotificationCenter.default.removeObserver(self)
    }

    private func requestSearch() {
        if !isRequesting {
            isRequesting = true
            if let token = self.requestSearchQueue.removeFirst(), !token.isEmpty {
                self.historyCellItem = CommonDao.s.selectCommonHistory(title: token, readNum: self.readCommonHistoryNum).objects(for: 4)
                self.searchHistoryCellItem = CommonDao.s.selectSearchHistory(title: token, readNum: self.readSearchHistoryNum).objects(for: 4)
                SuggestGetAPIRequestExecuter.request(token: token, completion: { (response) in
                    if let response = response, response.data.count > 0 {
                        // suggestあり
                        self.googleSearchCellItem = response.data.objects(for: 4)
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
}
