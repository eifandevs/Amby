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
    func footerViewModelDidAddThumbnail()
    func footerViewModelDidStartLoading(index: Int)
    func footerViewModelDidEndLoading(context: String)
}

class FooterViewModel {
    // 現在位置
    private var locationIndex: Int  = 0
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
    
    func getLocationIndex() -> Int {
        return locationIndex
    }
    
    @objc private func baseViewDidAddWebView(notification: Notification) {
        log.debug("[Footer Event]: baseViewDidAddWebView")
        if eachThumbnail.count > 0 {
            locationIndex = locationIndex + 1
        }
        
        // 新しいサムネイルを追加
        eachThumbnail.append(EachThumbnailItem())
        delegate?.footerViewModelDidAddThumbnail()
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
        if let url = (notification.object as! [String: String])["url"] {
            currentThumbnail.context = context
            currentThumbnail.url = url
        }
        delegate?.footerViewModelDidEndLoading(context: context)
    }
}
