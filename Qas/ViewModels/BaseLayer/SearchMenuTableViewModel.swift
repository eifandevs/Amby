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
}

class SearchMenuTableViewModel {
    let sectionItem: [String] = ["Google検索", "検索履歴", "閲覧履歴"]
    weak var delegate: SearchMenuTableViewModelDelegate?
    let googleSearchCellItem: [String] = []
    var searchHistoryCellItem: [SearchHistoryItem] = []
    var historyCellItem: [CommonHistoryItem] = []
    let readHistoryNum: Int = 31
    
    init() {
        // webview検索
        NotificationCenter.default.addObserver(forName: .searchMenuTableViewModelWillUpdateSearchToken, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else {
                return
            }
            log.debug("[SearchMenuTableView Event]: searchMenuTableViewModelWillUpdateSearchToken")
            let token = notification.object != nil ? (notification.object as! [String: String])["token"] : nil
            if let token = token, !token.isEmpty {
                self.historyCellItem = CommonDao.s.selectCommonHistory(title: token, readNum: self.readHistoryNum)
                self.searchHistoryCellItem = CommonDao.s.selectSearchHistory(title: token, readNum: self.readHistoryNum)
            } else {
                self.historyCellItem = []
                self.searchHistoryCellItem = []
            }
            self.delegate?.searchMenuViewWillUpdateLayout()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //    func getModelData(token: String) {
    //        if !token.isEmpty {
    //            historyCellItem = CommonDao.s.selectCommonHistory(title: token, readNum: readHistoryNum)
    //        }
    //        delegate?.searchMenuViewWillUpdateLayout()
    //    }
}
