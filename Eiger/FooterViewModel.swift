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
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewModelWillLoad(notification:)),
                           name: .footerViewModelWillLoad,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewModelWillAddWebView(notification:)),
                           name: .footerViewModelWillAddWebView,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewModelWillStartLoading(notification:)),
                           name: .footerViewModelWillStartLoading,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewModelWillEndLoading(notification:)),
                           name: .footerViewModelWillEndLoading,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewModelWillChangeWebView(notification:)),
                           name: .footerViewModelWillChangeWebView,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewModelWillRemoveWebView(notification:)),
                           name: .footerViewModelWillRemoveWebView,
                           object: nil)
    }
    
// MARK: Public Method
    
    func notifyChangeWebView(index: Int) {
        center.post(name: .baseViewModelWillChangeWebView, object: index)
    }
    
    func notifyRemoveWebView(index: Int) {
        center.post(name: .baseViewModelWillRemoveWebView, object: index)
    }
    
// MARK: Notification受信
    
    @objc private func footerViewModelWillChangeWebView(notification: Notification) {
        log.debug("[Footer Event]: footerViewModelWillChangeWebView")
        let index = notification.object as! Int
        if locationIndex != index {
            locationIndex = index
            delegate?.footerViewModelDidChangeThumbnail()
        }
    }

    @objc private func footerViewModelWillRemoveWebView(notification: Notification) {
        log.debug("[Footer Event]: footerViewModelWillRemoveWebView")
        let index = notification.object as! Int
        if locationIndex == index {
            // フロントの削除
            if index == eachThumbnail.count - 1 {
                // 最後の要素を削除する場合
                locationIndex = locationIndex - 1
            }
        } else {
            // フロントではない
        }
        eachThumbnail.remove(at: index)
        delegate?.footerViewModelDidRemoveThumbnail(index: index)
    }
    
    @objc private func footerViewModelWillLoad(notification: Notification) {
        log.debug("[Footer Event]: footerViewModelWillLoad")
        let eachHistory = notification.object as! [EachHistoryItem]
        
        
        if eachHistory.count > 0 {
            eachHistory.forEach { (item) in
                let thumbnailItem = EachThumbnailItem()
                thumbnailItem.context = item.context
                thumbnailItem.url = item.url
                thumbnailItem.title = item.title
                eachThumbnail.append(thumbnailItem)
            }
        }
        delegate?.footerViewModelDidLoadThumbnail(eachThumbnail: eachThumbnail)
    }
    
    @objc private func footerViewModelWillAddWebView(notification: Notification) {
        log.debug("[Footer Event]: footerViewModelWillAddWebView")
        let context = (notification.object as! [String: String])["context"]!
        
        // 新しいサムネイルを追加
        let thumbnailItem = EachThumbnailItem()
        thumbnailItem.context = context
        eachThumbnail.append(thumbnailItem)
        delegate?.footerViewModelDidAddThumbnail()
        
        locationIndex = eachThumbnail.count - 1
    }
    
    @objc private func footerViewModelWillStartLoading(notification: Notification) {
        log.debug("[Footer Event]: footerViewModelWillStartLoading")
        // FooterViewに通知をする
        
        delegate?.footerViewModelDidStartLoading(index: locationIndex)
    }
    
    @objc private func footerViewModelWillEndLoading(notification: Notification) {
        log.debug("[Footer Event]: footerViewModelWillEndLoading")
        // FooterViewに通知をする
        let context = (notification.object as! [String: String])["context"]!
        let url = (notification.object as! [String: String])["url"]!
        let title = (notification.object as! [String: String])["title"]!
        
        for (index, thumbnail) in eachThumbnail.enumerated() {
            if thumbnail.context == context {
                thumbnail.url = url
                thumbnail.title = title
                delegate?.footerViewModelDidEndLoading(context: context, index: index)
                break
            }
        }
    }
}
