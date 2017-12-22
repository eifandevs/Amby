//
//  FavoriteDataModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class FavoriteDataModel {
    
    static let s = FavoriteDataModel()
    /// 通知センター
    private let center = NotificationCenter.default
    
    func insert(favorites: [Favorite]) {
        CommonDao.s.insert(data: favorites)
        center.post(name: .favoriteDataModelDidInsert, object: nil)
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
    
    func delete(favorites: [Favorite]? = nil) {
        if let favorites = favorites {
            CommonDao.s.delete(data: favorites)
        } else {
            // 削除対象が指定されていない場合は、すべて削除する
            CommonDao.s.delete(data: select())
        }
        center.post(name: .favoriteDataModelDidRemove, object: nil)
    }
    
    /// お気に入りの更新チェック
    func reload() {
        let history = PageHistoryDataModel.s.currentHistory
        center.post(name: .favoriteDataModelDidReload, object: history.url)
    }
    
    /// お気に入り登録
    func register() {
        if (!PageHistoryDataModel.s.currentHistory.url.isEmpty && !PageHistoryDataModel.s.currentHistory.title.isEmpty) {
            let fd = Favorite()
            fd.title = PageHistoryDataModel.s.currentHistory.title
            fd.url = PageHistoryDataModel.s.currentHistory.url
            
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
