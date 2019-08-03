//
//  FavoriteHanderUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum FavoriteHanderUseCaseAction {
    case load(url: String)
    case update(isSwitch: Bool)
}

/// お気に入りユースケース
public final class FavoriteHanderUseCase {
    public static let s = FavoriteHanderUseCase()

    public let rx_action = PublishSubject<FavoriteHanderUseCaseAction>()

    // models
    private var tabDataModel: TabDataModelProtocol!
    private var favoriteDataModel: FavoriteDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
        favoriteDataModel = FavoriteDataModel.s
    }

    private func setupRx() {
        // エラー監視
        Observable
            .merge([
                tabDataModel.rx_action
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

                if let currentTab = self.tabDataModel.currentTab, !currentTab.url.isEmpty {
                    self.rx_action.onNext(.update(isSwitch: self.favoriteDataModel.select().map({ $0.url }).contains(currentTab.url)))
                } else {
                    self.rx_action.onNext(.update(isSwitch: false))
                }
            }
            .disposed(by: disposeBag)
    }

    /// ロードリクエスト
    public func load(url: String) {
        rx_action.onNext(.load(url: url))
    }
}
