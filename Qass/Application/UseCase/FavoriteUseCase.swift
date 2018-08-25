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
final class FavoriteUseCase {

    static let s = FavoriteUseCase()

    /// ロードリクエスト通知用RX
    let rx_favoriteUseCaseDidRequestLoad = PublishSubject<String>()

    /// お気に入り更新通知用RX
    let rx_favoriteUseCaseDidChangeFavorite = Observable
        .merge([
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert.flatMap { _ in Observable.just(()) },
            PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove.flatMap { _ in Observable.just(()) },
            FavoriteDataModel.s.rx_favoriteDataModelDidInsert.flatMap { _ in Observable.just(()) },
            FavoriteDataModel.s.rx_favoriteDataModelDidRemove,
            FavoriteDataModel.s.rx_favoriteDataModelDidReload.flatMap { _ in Observable.just(()) }
            ])
        .flatMap { _ -> Observable<Bool> in
            if let currentHistory = PageHistoryDataModel.s.currentHistory, !currentHistory.url.isEmpty {
                return Observable.just(FavoriteDataModel.s.select().map({ $0.url }).contains(currentHistory.url))
            } else {
                return Observable.just(false)
            }
    }

    /// お気に入り更新
    func update() {
        FavoriteDataModel.s.update()
    }

    /// ロードリクエスト
    func load(url: String) {
        rx_favoriteUseCaseDidRequestLoad.onNext(url)
    }
}
