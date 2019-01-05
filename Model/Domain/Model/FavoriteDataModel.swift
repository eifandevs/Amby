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

enum FavoriteDataModelAction {
    case insert(favorites: [Favorite])
    case delete
    case deleteAll
    case reload(url: String)
}

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
    /// アクション通知用RX
    let rx_action = PublishSubject<FavoriteDataModelAction>()
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

        if case .success = result {
            rx_action.onNext(.insert(favorites: favorites))
        } else {
            rx_error.onNext(.store)
        }
    }

    func select() -> [Favorite] {
        let result = repository.select(type: Favorite.self)
        if case let .success(favorite) = result {
            return favorite as! [Favorite]
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    func select(id: String) -> [Favorite] {
        let result = repository.select(type: Favorite.self)
        if case let .success(favorite) = result {
            return (favorite as! [Favorite]).filter({ $0.id == id })
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    func select(url: String) -> [Favorite] {
        let result = repository.select(type: Favorite.self)
        if case let .success(favorite) = result {
            return (favorite as! [Favorite]).filter({ $0.url == url })
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        let result = repository.delete(data: select())
        if case .success = result {
            rx_action.onNext(.deleteAll)
        } else {
            rx_error.onNext(.delete)
        }
    }

    func delete(favorites: [Favorite]) {
        let result = repository.delete(data: favorites)
        if case .success = result {
            rx_action.onNext(.delete)
        } else {
            rx_error.onNext(.delete)
        }
    }

    /// お気に入りの更新チェック
    func reload() {
        if let currentHistory = PageHistoryDataModel.s.currentHistory {
            rx_action.onNext(.reload(url: currentHistory.url))
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
