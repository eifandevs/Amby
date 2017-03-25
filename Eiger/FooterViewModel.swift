//
//  FooterViewModel.swift
//  Eiger
//
//  Created by tenma on 2017/03/23.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class FooterViewModel {
    // 現在位置
    private var locationIndex: Int  = UserDefaults.standard.integer(forKey: AppDataManager.shared.locationIndexKey)
    private var eachThumbnail: [EachThumbnailItem] = []
    
    init() {
        // Notification Center登録
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(type(of: self).notified(notification:)),
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
    
    @objc private func notified(notification: Notification) {
        print("呼ばれた \(notification)")
    }
    
    private func saveThumbnail() {
    }
    
    private func storeThumbnail() {
    }
}
