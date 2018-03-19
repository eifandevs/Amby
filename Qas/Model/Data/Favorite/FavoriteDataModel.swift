//
//  FavoriteDataModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class FavoriteDataModel {
    /// お気に入り追加通知用RX
    let rx_favoriteDataModelDidInsert = PublishSubject<()>()
    /// お気に入り削除通知用RX
    let rx_favoriteDataModelDidRemove = PublishSubject<()>()
    /// お気に入り更新通知用RX
    let rx_favoriteDataModelDidReload = PublishSubject<String>()
    
    static let s = FavoriteDataModel()
    /// 通知センター
    private let center = NotificationCenter.default
    
    func insert(favorites: [Favorite]) {
        CommonDao.s.insert(data: favorites)
        rx_favoriteDataModelDidInsert.onNext(())
    }
    
    func select(id: String? = nil, url: String? = nil) -> [Favorite] {
        let favorites = CommonDao.s.select(type: Favorite.self) as! [Favorite]
        if let id = id {
            return favorites.filter({ $0.id == id })
        } else if let url = url {
            return favorites.filter({ $0.url == url })
        }
        return favorites
    }
    
    func delete(favorites: [Favorite]? = nil, notify: Bool = true) {
        if let favorites = favorites {
            CommonDao.s.delete(data: favorites)
        } else {
            // 削除対象が指定されていない場合は、すべて削除する
            CommonDao.s.delete(data: select())
        }
        
        // 通知する
        if notify {
            rx_favoriteDataModelDidRemove.onNext(())
        }
    }
    
    /// お気に入りの更新チェック
    func reload() {
        if let currentHistory = PageHistoryDataModel.s.currentHistory {
            rx_favoriteDataModelDidReload.onNext(currentHistory.url)
        }
    }
    
    /// お気に入り登録
    func register() {
        if let currentHistory = PageHistoryDataModel.s.currentHistory {
            if (!currentHistory.url.isEmpty && !currentHistory.title.isEmpty) {
                let fd = Favorite()
                fd.title = currentHistory.title
                fd.url = currentHistory.url
                
                if let favorite = select(url: fd.url).first {
                    // すでに登録済みの場合は、お気に入りから削除する
                    delete(favorites: [favorite])
                } else {
                    insert(favorites: [fd])
                    // ヘッダーのお気に入りアイコン更新
                    NotificationManager.presentNotification(message: MessageConst.NOTIFICATION_REGISTER_BOOK_MARK)
                }
            } else {
                NotificationManager.presentNotification(message: MessageConst.NOTIFICATION_REGISTER_BOOK_MARK_ERROR)
            }
        }
    }
}
