//
//  FooterViewModel.swift
//  Eiger
//
//  Created by tenma on 2017/03/23.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

protocol FooterViewModelDelegate: class {
    func footerViewModelDidAddThumbnail(pageHistory: PageHistory)
    func footerViewModelDidChangeThumbnail(context: String)
    func footerViewModelDidRemoveThumbnail(context: String, pageExist: Bool)
    func footerViewModelDidStartLoading(context: String)
    func footerViewModelDidEndLoading(context: String, title: String)
}

class FooterViewModel {
    /// 現在位置
    var pageHistories: [PageHistory] {
        return PageHistoryDataModel.s.histories
    }
    
    var currentHistory: PageHistory {
        return PageHistoryDataModel.s.currentHistory
    }
    
    var currentContext: String {
        return PageHistoryDataModel.s.currentContext
    }
    
    var currentLocation: Int {
        return PageHistoryDataModel.s.currentLocation
    }
    
    weak var delegate: FooterViewModelDelegate?
    
    /// 通知センター
    let center = NotificationCenter.default
    
    init(index: Int) {
        // webview追加
        center.addObserver(forName: .pageHistoryDataModelDidInsert, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: pageHistoryDataModelDidInsert")
            let pageHistory = notification.object as! PageHistory
            
            // 新しいサムネイルを追加
            self.delegate?.footerViewModelDidAddThumbnail(pageHistory: pageHistory)
        }
        // webviewロード開始
        center.addObserver(forName: .pageHistoryDataModelDidStartLoading, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: pageHistoryDataModelDidStartLoading")
            // FooterViewに通知をする
            self.delegate?.footerViewModelDidStartLoading(context: notification.object as! String)
        }
        // webviewロード完了
        center.addObserver(forName: .pageHistoryDataModelDidEndLoading, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: pageHistoryDataModelDidEndLoading")
            // FooterViewに通知をする
            let context = notification.object as! String
            let pageHistory = D.find(PageHistoryDataModel.s.histories, callback: { $0.context == context })!
            self.delegate?.footerViewModelDidEndLoading(context: context, title: pageHistory.title)
        }

        // webview切り替え
        center.addObserver(forName: .pageHistoryDataModelDidChange, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: pageHistoryDataModelDidChange")
            self.delegate?.footerViewModelDidChangeThumbnail(context: notification.object as! String)
        }
        
        // webview削除
        center.addObserver(forName: .pageHistoryDataModelDidRemove, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: pageHistoryDataModelDidRemove")
            let context = (notification.object as! [String: Any])["context"] as! String
            let pageExist = (notification.object as! [String: Any])["pageExist"] as! Bool
            
            // 実データの削除
            try! FileManager.default.removeItem(atPath: Util.thumbnailFolderUrl(folder: context).path)
            self.delegate?.footerViewModelDidRemoveThumbnail(context: context, pageExist: pageExist)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: Public Method
    
    func changePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.change(context: context)
    }
    
    func removePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.remove(context: context)
    }
}
