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
                           selector: #selector(type(of: self).footerViewLoad(notification:)),
                           name: .footerViewLoad,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewAddWebView(notification:)),
                           name: .footerViewAddWebView,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewStartLoading(notification:)),
                           name: .footerViewStartLoading,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).footerViewEndLoading(notification:)),
                           name: .footerViewEndLoading,
                           object: nil)
    }
    
// MARK: Public Method
    
    func notifyChangeWebView(index: Int) {
        center.post(name: .baseViewChangeWebView, object: index)
    }

// MARK: Notification受信
    
    @objc private func footerViewLoad(notification: Notification) {
        log.debug("[Footer Event]: footerViewLoad")
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
    
    @objc private func footerViewAddWebView(notification: Notification) {
        log.debug("[Footer Event]: footerViewAddWebView")
        let context = (notification.object as! [String: String])["context"]!

        // 新しいサムネイルを追加
        let thumbnailItem = EachThumbnailItem()
        thumbnailItem.context = context
        eachThumbnail.append(thumbnailItem)
        delegate?.footerViewModelDidAddThumbnail()
        
        locationIndex = eachThumbnail.count - 1
    }
    
    @objc private func footerViewStartLoading(notification: Notification) {
        log.debug("[Footer Event]: footerViewStartLoading")
        // FooterViewに通知をする
        
        delegate?.footerViewModelDidStartLoading(index: locationIndex)
    }
    
    @objc private func footerViewEndLoading(notification: Notification) {
        log.debug("[Footer Event]: footerViewEndLoading")
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
