//
//  AboutUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// アバウトユースケース
public final class AboutUseCase {
    public static let s = AboutUseCase()

    /// ロードリクエスト通知用RX
    public let rx_aboutUseCaseDidRequestOpen = PublishSubject<()>()

    private init() {}

    /// About表示
    public func open() {
        rx_aboutUseCaseDidRequestOpen.onNext(())
    }
}
