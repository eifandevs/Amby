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

    init(index: Int) {
        // Notification Center登録
        locationIndex = index
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(type(of: self).baseViewDidLoad(notification:)),
                           name: .baseViewDidLoad,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).baseViewDidAddWebView(notification:)),
                           name: .baseViewDidAddWebView,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).baseViewDidStartLoading(notification:)),
                           name: .baseViewDidStartLoading,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(type(of: self).baseViewDidEndLoading(notification:)),
                           name: .baseViewDidEndLoading,
                           object: nil)
    }

    @objc private func baseViewDidLoad(notification: Notification) {
        log.debug("[Footer Event]: baseViewDidLoad")
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
    
    @objc private func baseViewDidAddWebView(notification: Notification) {
        log.debug("[Footer Event]: baseViewDidAddWebView")
        let context = (notification.object as! [String: String])["context"]!

        // 新しいサムネイルを追加
        let thumbnailItem = EachThumbnailItem()
        thumbnailItem.context = context
        eachThumbnail.append(thumbnailItem)
        delegate?.footerViewModelDidAddThumbnail()
        
        locationIndex = eachThumbnail.count - 1
    }
    
    @objc private func baseViewDidStartLoading(notification: Notification) {
        log.debug("[Footer Event]: baseViewDidStartLoading")
        // FooterViewに通知をする
        
        delegate?.footerViewModelDidStartLoading(index: locationIndex)
    }
    
    @objc private func baseViewDidEndLoading(notification: Notification) {
        log.debug("[Footer Event]: baseViewDidEndLoading")
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
