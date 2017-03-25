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
}

class FooterViewModel {
    // 現在位置
    private var locationIndex: Int  = 0
    private var eachThumbnail: [EachThumbnailItem] = []
    
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
        
        // eachThumbnail読み込み
        do {
            let data = try Data(contentsOf: AppDataManager.shared.eachThumbnailPath)
            eachThumbnail = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EachThumbnailItem]
            log.debug("each thumbnail read")
            
            // TODO: eachThumnailからそれぞれのサムネイルを復元
        } catch let error as NSError {
            log.error("failed to read each thumbnail: \(error)")
        }
    }
    
    @objc private func baseViewDidAddWebView(notification: Notification) {
        log.debug("footer is notified. Name: baseViewDidAddWebView")
        if eachThumbnail.count > 0 {
            locationIndex = locationIndex + 1
        }
        
        // 新しいサムネイルを追加
        eachThumbnail.append(EachThumbnailItem())
        delegate?.footerViewModelDidAddThumbnail()
    }
    
    @objc private func baseViewDidStartLoading(notification: Notification) {
        log.debug("footer is notified. Name: baseViewDidStartLoading")
        // FooterViewに通知をする
        delegate?.footerViewModelDidStartLoading(index: locationIndex)
    }
    
    private func saveThumbnail() {
    }
    
    private func storeThumbnail() {
    }
}
