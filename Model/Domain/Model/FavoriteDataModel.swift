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

enum FavoriteDataModelError {
    case get
    case store
}

extension FavoriteDataModelError: ModelError {
    var message: String {
        switch self {
        case .get:
            return MessageConst.NOTIFICATION.GET_FAVORITE_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_FAVORITE_ERROR
        }
    }
}

final class FavoriteDataModel {
    /// お気に入り追加通知用RX
    let rx_favoriteDataModelDidInsert = PublishSubject<([Favorite])>()
    /// お気に入り削除通知用RX
    let rx_favoriteDataModelDidDelete = PublishSubject<()>()
    /// お気に入り全削除通知用RX
    let rx_favoriteDataModelDidDeleteAll = PublishSubject<()>()
    /// お気に入り削除失敗通知用RX
    let rx_favoriteDataModelDidDeleteFailure = PublishSubject<()>()
    /// お気に入り更新通知用RX
    let rx_favoriteDataModelDidReload = PublishSubject<String>()
    /// お気に入り登録失敗通知用RX
    let rx_favoriteDataModelDidInsertFailure = PublishSubject<()>()
    /// お気に入り情報取得失敗通知用RX
    let rx_favoriteDataModelDidGetFailure = PublishSubject<()>()
    /// エラー通知用RX
    let rx_error = PublishSubject<FavoriteDataModelError>()
    
    static let s = FavoriteDataModel()
    /// 通知センター
    private let center = NotificationCenter.default
    /// DBプロバイダー
    let repository = DBRepository()

    private init() {}

    func insert(favorites: [Favorite]) {
        let result = repository.insert(data: favorites)
        switch result {
        case .success(_):
            rx_favoriteDataModelDidInsert.onNext(favorites)
        case .failure(_):
            rx_error.onNext(.insert)
        }
    }

    func select() -> [Favorite] {
        let result = repository.select(type: Favorite.self)
        switch result {
        case let .success(favorite):
            return favorite as! [Favorite]
        case .failure(_):
            rx_error.onNext(.get)
            return []
        }
    }

    func select(id: String) -> [Favorite] {
        if let favorites = repository.select(type: Favorite.self) as? [Favorite] {
            return favorites.filter({ $0.id == id })
        } else {
            log.error("fail to select favorite")
            return []
        }
    }

    func select(url: String) -> [Favorite] {
        if let favorites = repository.select(type: Favorite.self) as? [Favorite] {
            return favorites.filter({ $0.url == url })
        } else {
            log.error("fail to select favorite")
            return []
        }
    }

    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        if repository.delete(data: select()) {
            rx_favoriteDataModelDidDeleteAll.onNext(())
        } else {
            rx_favoriteDataModelDidDeleteFailure.onNext(())
        }
    }

    func delete(favorites: [Favorite]) {
        if repository.delete(data: favorites) {
            rx_favoriteDataModelDidDelete.onNext(())
        } else {
            rx_favoriteDataModelDidDeleteFailure.onNext(())
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
                }
            } else {
                rx_favoriteDataModelDidGetFailure.onNext(())
            }
        }
    }
}
