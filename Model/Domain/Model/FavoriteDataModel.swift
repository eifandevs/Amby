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
    case delete
}

extension FavoriteDataModelError: ModelError {
    var message: String {
        switch self {
        case .get:
            return MessageConst.NOTIFICATION.GET_FAVORITE_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_FAVORITE_ERROR
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_FAVORITE_ERROR
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
        case .success:
            rx_favoriteDataModelDidInsert.onNext(favorites)
        case .failure:
            rx_error.onNext(.store)
        }
    }

    func select() -> [Favorite] {
        let result = repository.select(type: Favorite.self)
        switch result {
        case let .success(favorite):
            return favorite as! [Favorite]
        case .failure:
            rx_error.onNext(.get)
            return []
        }
    }

    func select(id: String) -> [Favorite] {
        let result = repository.select(type: Favorite.self)
        switch result {
        case let .success(favorite):
            return (favorite as! [Favorite]).filter({ $0.id == id })
        case .failure:
            rx_error.onNext(.get)
            return []
        }
    }

    func select(url: String) -> [Favorite] {
        let result = repository.select(type: Favorite.self)
        switch result {
        case let .success(favorite):
            return (favorite as! [Favorite]).filter({ $0.url == url })
        case .failure:
            rx_error.onNext(.get)
            return []
        }
    }

    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        let result = repository.delete(data: select())
        switch result {
        case .success:
            rx_favoriteDataModelDidDeleteAll.onNext(())
        case .failure:
            rx_error.onNext(.delete)
        }
    }

    func delete(favorites: [Favorite]) {
        let result = repository.delete(data: favorites)
        switch result {
        case .success:
            rx_favoriteDataModelDidDelete.onNext(())
        case .failure:
            rx_error.onNext(.delete)
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
                rx_error.onNext(.get)
            }
        }
    }
}
