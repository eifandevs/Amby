//
//  FooterViewModel.swift
//  Eiger
//
//  Created by tenma on 2017/03/23.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

protocol FooterViewModelDelegate: class {
    func footerViewModelDidLoadThumbnail(pageHistories: [PageHistory])
    func footerViewModelDidAddThumbnail(context: String, isPrivateMode: Bool)
    func footerViewModelDidChangeThumbnail()
    func footerViewModelDidRemoveThumbnail(index: Int)
    func footerViewModelDidStartLoading(index: Int)
    func footerViewModelDidEndLoading(context: String, title: String, index: Int)
}

class FooterViewModel {
    // 現在位置
    var locationIndex: Int  = 0
    private var pageHistories: [PageHistory] = []
    private var currentThumbnail: PageHistory {
        return pageHistories[locationIndex]
    }
    
    weak var delegate: FooterViewModelDelegate?
    
    // 通知センター
    let center = NotificationCenter.default
    
    init(index: Int) {
        // Notification Center登録
        locationIndex = index
        // 初期ロード開始
        center.addObserver(forName: .footerViewModelWillLoad, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: footerViewModelWillLoad")
            self.pageHistories = notification.object as! [PageHistory]
            self.delegate?.footerViewModelDidLoadThumbnail(pageHistories: self.pageHistories)
        }
        
        // webview追加
        center.addObserver(forName: .footerViewModelWillAddWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: footerViewModelWillAddWebView")
            let pageHistory = notification.object as! PageHistory
            
            // 新しいサムネイルを追加
            self.pageHistories.append(pageHistory)
            self.locationIndex = self.pageHistories.count - 1
            self.delegate?.footerViewModelDidAddThumbnail(context: pageHistory.context, isPrivateMode: pageHistory.isPrivate == "true")
        }
        // webviewロード開始
        center.addObserver(forName: .footerViewModelWillStartLoading, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: footerViewModelWillStartLoading")
            // FooterViewに通知をする
            self.delegate?.footerViewModelDidStartLoading(index: self.locationIndex)
        }
        // webviewロード完了
        center.addObserver(forName: .footerViewModelWillEndLoading, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: footerViewModelWillEndLoading")
            // FooterViewに通知をする
            let context = (notification.object as! [String: String])["context"]!
            let url = (notification.object as! [String: String])["url"]!
            let title = (notification.object as! [String: String])["title"]!
            
            for (index, thumbnail) in self.pageHistories.enumerated() {
                if thumbnail.context == context {
                    thumbnail.url = url
                    thumbnail.title = title
                    self.delegate?.footerViewModelDidEndLoading(context: context, title: title, index: index)
                    break
                }
            }
        }
        // webview切り替え
        center.addObserver(forName: .footerViewModelWillChangeWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: footerViewModelWillChangeWebView")
            let index = notification.object as! Int
            if self.locationIndex != index {
                self.locationIndex = index
                self.delegate?.footerViewModelDidChangeThumbnail()
            }
        }
        // webview削除
        center.addObserver(forName: .footerViewModelWillRemoveWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[Footer Event]: footerViewModelWillRemoveWebView")
            let index = notification.object as! Int
            
            // 実データの削除
            try! FileManager.default.removeItem(atPath: AppConst.thumbnailFolderUrl(folder: self.pageHistories[index].context).path)
            
            if ((index != 0 && self.locationIndex == index && index == self.pageHistories.count - 1) || (index < self.locationIndex)) {
                // フロントの削除
                // 最後の要素を削除する場合
                self.locationIndex = self.locationIndex - 1
            }
            self.pageHistories.remove(at: index)
            self.delegate?.footerViewModelDidRemoveThumbnail(index: index)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: Public Method
    
    func notifyChangeWebView(index: Int) {
        center.post(name: .baseViewModelWillChangeWebView, object: index)
    }
    
    func notifyRemoveWebView(index: Int) {
        center.post(name: .baseViewModelWillRemoveWebView, object: index)
    }
}
