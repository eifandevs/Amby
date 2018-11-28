//
//  FavoriteUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// お気に入りユースケース
public final class FavoriteUseCase {
    public static let s = FavoriteUseCase()

    /// ロードリクエスト通知用RX
    public let rx_favoriteUseCaseDidRequestLoad = PublishSubject<String>()

    /// お気に入り更新通知用RX
    public let rx_favoriteUseCaseDidChangeFavorite = Observable
        .merge([
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove.flatMap { _ in Observable.just(()) },
            FavoriteDataModel.s.rx_favoriteDataModelDidInsert.flatMap { _ in Observable.just(()) },
            FavoriteDataModel.s.rx_favoriteDataModelDidDelete,
            FavoriteDataModel.s.rx_favoriteDataModelDidReload.flatMap { _ in Observable.just(()) },
        ])
        .flatMap { _ -> Observable<Bool> in
            if let currentHistory = PageHistoryDataModel.s.currentHistory, !currentHistory.url.isEmpty {
                return Observable.just(FavoriteDataModel.s.select().map({ $0.url }).contains(currentHistory.url))
            } else {
                return Observable.just(false)
            }
        }

    private init() {}

    public func select() -> [Favorite] {
        return FavoriteDataModel.s.select()
    }

    public func select(id: String) -> [Favorite] {
        return FavoriteDataModel.s.select(id: id)
    }

    public func select(url: String) -> [Favorite] {
        return FavoriteDataModel.s.select(url: url)
    }

    /// お気に入り更新
    public func update() {
        FavoriteDataModel.s.update()
    }

    /// ロードリクエスト
    public func load(url: String) {
        rx_favoriteUseCaseDidRequestLoad.onNext(url)
    }

    public func delete() {
        FavoriteDataModel.s.delete()
    }

    public func delete(favorites: [Favorite]) {
        FavoriteDataModel.s.delete(favorites: favorites)
    }
}
