//
//  FavoriteUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

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

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        setupRx()
    }

    private func setupRx() {
        // エラー監視
        Observable
            .merge([
                PageHistoryDataModel.s.rx_action
                    .filter { action -> Bool in
                        switch action {
                        case .append, .change, .insert, .delete:
                            return true
                        default:
                            return false
                        }
                    }
                    .flatMap { _ in Observable.just(()) },
                FavoriteDataModel.s.rx_action
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

                if let currentHistory = PageHistoryDataModel.s.currentHistory, !currentHistory.url.isEmpty {
                    self.rx_action.onNext(.update(isSwitch: FavoriteDataModel.s.select().map({ $0.url }).contains(currentHistory.url)))
                } else {
                    self.rx_action.onNext(.update(isSwitch: false))
                }
            }
            .disposed(by: disposeBag)
    }

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
        rx_action.onNext(.load(url: url))
    }

    public func delete() {
        FavoriteDataModel.s.delete()
    }

    public func delete(favorites: [Favorite]) {
        FavoriteDataModel.s.delete(favorites: favorites)
    }
}
