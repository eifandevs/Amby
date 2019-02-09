//
//  FavoriteUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum FavoriteUseCaseAction {
    case load(url: String)
    case update(isSwitch: Bool)
}

/// お気に入りユースケース
public final class FavoriteUseCase {
    public static let s = FavoriteUseCase()

    public let rx_action = PublishSubject<FavoriteUseCaseAction>()

    // models
    private var pageHistoryDataModel: PageHistoryDataModelProtocol!
    private var favoriteDataModel: FavoriteDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    private func setupProtocolImpl() {
        pageHistoryDataModel = PageHistoryDataModel.s
        favoriteDataModel = FavoriteDataModel.s
    }

    private func setupRx() {
        // エラー監視
        Observable
            .merge([
                pageHistoryDataModel.rx_action
                    .filter { action -> Bool in
                        switch action {
                        case .append, .change, .insert, .delete:
                            return true
                        default:
                            return false
                        }
                    }
                    .flatMap { _ in Observable.just(()) },
                favoriteDataModel.rx_action
                    .filter { action -> Bool in
                        switch action {
                        case .insert, .delete, .reload:
                            return true
                        default:
                            return false
                        }
                    }
                    .flatMap { _ in Observable.just(()) }
            ])
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }

                if let currentHistory = self.pageHistoryDataModel.currentHistory, !currentHistory.url.isEmpty {
                    self.rx_action.onNext(.update(isSwitch: self.favoriteDataModel.select().map({ $0.url }).contains(currentHistory.url)))
                } else {
                    self.rx_action.onNext(.update(isSwitch: false))
                }
            }
            .disposed(by: disposeBag)
    }

    public func select() -> [Favorite] {
        return favoriteDataModel.select()
    }

    public func select(id: String) -> [Favorite] {
        return favoriteDataModel.select(id: id)
    }

    public func select(url: String) -> [Favorite] {
        return favoriteDataModel.select(url: url)
    }

    /// お気に入り更新
    public func update() {
        if let currentHistory = pageHistoryDataModel.currentHistory {
            favoriteDataModel.update(currentHistory: currentHistory)
        }
    }

    /// ロードリクエスト
    public func load(url: String) {
        rx_action.onNext(.load(url: url))
    }

    public func delete() {
        FavoriteDataModel.s.delete()
    }

    public func delete(favorites: [Favorite]) {
        FavoriteDataModel.s.delete(favorites: favorites)
    }
}
