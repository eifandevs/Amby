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

    /// お気に入り更新
    func update() {
        FavoriteDataModel.s.update()
    }

    /// ロードリクエスト
    func load(url: String) {
        rx_favoriteUseCaseDidRequestLoad.onNext(url)
    }
}
