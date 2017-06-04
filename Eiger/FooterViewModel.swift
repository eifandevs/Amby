//
//  FooterViewModel.swift
//  Eiger
//
//  Created by tenma on 2017/03/23.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Bond

protocol FooterViewModelDelegate {
    func footerViewModelDidLoadThumbnail(eachThumbnail: [EachThumbnailItem])
    func footerViewModelDidAddThumbnail()
    func footerViewModelDidChangeThumbnail()
    func footerViewModelDidRemoveThumbnail(index: Int)
    func footerViewModelDidStartLoading(index: Int)
    func footerViewModelDidEndLoading(context: String, index: Int)
}

class FooterViewModel {
    // 現在位置
    var locationIndex: Int  = 0
    private var eachThumbnail: [EachThumbnailItem] = []
    private var currentThumbnail: EachThumbnailItem {
        get {
            return eachThumbnail[locationIndex]
        }
    }
    
    var delegate: FooterViewModelDelegate?
    
    // 通知センター
    let center = NotificationCenter.default
    
    init(index: Int) {
        // Notification Center登録
        locationIndex = index
        // 初期ロード開始
        center.addObserver(forName: .footerViewModelWillLoad, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[Footer Event]: footerViewModelWillLoad")
            let eachHistory = notification.object as! [EachHistoryItem]
            
            
            if eachHistory.count > 0 {
                eachHistory.forEach { (item) in
                    let thumbnailItem = EachThumbnailItem()
                    thumbnailItem.context = item.context
                    thumbnailItem.url = item.url
                    thumbnailItem.title = item.title
                    self!.eachThumbnail.append(thumbnailItem)
                }
            }
            self!.delegate?.footerViewModelDidLoadThumbnail(eachThumbnail: self!.eachThumbnail)
        }
        // webview追加
        center.addObserver(forName: .footerViewModelWillAddWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[Footer Event]: footerViewModelWillAddWebView")
            let context = (notification.object as! [String: String])["context"]!
            
            // 新しいサムネイルを追加
            let thumbnailItem = EachThumbnailItem()
            thumbnailItem.context = context
            self!.eachThumbnail.append(thumbnailItem)
            self!.delegate?.footerViewModelDidAddThumbnail()
            
            self!.locationIndex = self!.eachThumbnail.count - 1
        }
        // webviewロード開始
        center.addObserver(forName: .footerViewModelWillStartLoading, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[Footer Event]: footerViewModelWillStartLoading")
            // FooterViewに通知をする
            self!.delegate?.footerViewModelDidStartLoading(index: self!.locationIndex)
        }
        // webviewロード完了
        center.addObserver(forName: .footerViewModelWillEndLoading, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[Footer Event]: footerViewModelWillEndLoading")
            // FooterViewに通知をする
            let context = (notification.object as! [String: String])["context"]!
            let url = (notification.object as! [String: String])["url"]!
            let title = (notification.object as! [String: String])["title"]!
            
            for (index, thumbnail) in self!.eachThumbnail.enumerated() {
                if thumbnail.context == context {
                    thumbnail.url = url
                    thumbnail.title = title
                    self!.delegate?.footerViewModelDidEndLoading(context: context, index: index)
                    break
                }
            }
        }
        // webview切り替え
        center.addObserver(forName: .footerViewModelWillChangeWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[Footer Event]: footerViewModelWillChangeWebView")
            let index = notification.object as! Int
            if self!.locationIndex != index {
                self!.locationIndex = index
                self!.delegate?.footerViewModelDidChangeThumbnail()
            }
        }
        // webview削除
        center.addObserver(forName: .footerViewModelWillRemoveWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[Footer Event]: footerViewModelWillRemoveWebView")
            let index = notification.object as! Int
            
            // 実データの削除
            try! FileManager.default.removeItem(atPath: AppDataManager.shared.thumbnailFolderPath(folder: self!.eachThumbnail[index].context).path)
            
            if ((index != 0 && self!.locationIndex == index && index == self!.eachThumbnail.count - 1) || (index < self!.locationIndex)) {
                // フロントの削除
                // 最後の要素を削除する場合
                self!.locationIndex = self!.locationIndex - 1
            }
            self!.eachThumbnail.remove(at: index)
            self!.delegate?.footerViewModelDidRemoveThumbnail(index: index)
        }
    }
    
// MARK: Public Method
    
    func notifyChangeWebView(index: Int) {
        center.post(name: .baseViewModelWillChangeWebView, object: index)
    }
    
    func notifyRemoveWebView(index: Int) {
        center.post(name: .baseViewModelWillRemoveWebView, object: index)
    }
}
