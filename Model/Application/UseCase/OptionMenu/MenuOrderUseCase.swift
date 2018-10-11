//
//  MenuOrderUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/11.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// メニューオーダーユースケース
public final class MenuOrderUseCase {
    public static let s = MenuOrderUseCase()

    /// オープンリクエスト通知用RX
    public let rx_menuOrderUseCaseDidRequestOpen = PublishSubject<()>()

    private init() {}

    /// ライセンス表示
    public func open() {
        rx_menuOrderUseCaseDidRequestOpen.onNext(())
    }
}
