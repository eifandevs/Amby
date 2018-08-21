//
//  FavoriteDataModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class FavoriteDataModel {
    /// お気に入り追加通知用RX
    let rx_favoriteDataModelDidInsert = PublishSubject<([Favorite])>()
    /// お気に入り削除通知用RX
    let rx_favoriteDataModelDidRemove = PublishSubject<()>()
    /// お気に入り更新通知用RX
    let rx_favoriteDataModelDidReload = PublishSubject<String>()

    static let s = FavoriteDataModel()
    /// 通知センター
    private let center = NotificationCenter.default
    /// DBプロバイダー
    let repository = DBRepository()

    func insert(favorites: [Favorite]) {
        repository.insert(data: favorites)
        rx_favoriteDataModelDidInsert.onNext(favorites)
    }

    func select(id: String? = nil, url: String? = nil) -> [Favorite] {
        if let favorites = repository.select(type: Favorite.self) as? [Favorite] {
            if let id = id {
                return favorites.filter({ $0.id == id })
            } else if let url = url {
                return favorites.filter({ $0.url == url })
            }
            return favorites
        } else {
            return []
        }
    }

    func delete(favorites: [Favorite]? = nil, notify: Bool = true) {
        if let favorites = favorites {
            repository.delete(data: favorites)
        } else {
            // 削除対象が指定されていない場合は、すべて削除する
            repository.delete(data: select())
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

    /// update favorite
    func update() {
        if let currentHistory = PageHistoryDataModel.s.currentHistory {
            if !currentHistory.url.isEmpty && !currentHistory.title.isEmpty {
                let fd = Favorite()
                fd.title = currentHistory.title
                fd.url = currentHistory.url

                if let favorite = select(url: fd.url).first {
                    // すでに登録済みの場合は、お気に入りから削除する
                    delete(favorites: [favorite])
                } else {
                    insert(favorites: [fd])
                    // ヘッダーのお気に入りアイコン更新
                    NotificationManager.presentNotification(message: MessageConst.NOTIFICATION.REGISTER_BOOK_MARK)
                }
            } else {
                NotificationManager.presentNotification(message: MessageConst.NOTIFICATION.REGISTER_BOOK_MARK_ERROR)
            }
        }
    }
}
