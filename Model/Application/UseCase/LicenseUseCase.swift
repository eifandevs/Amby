//
//  LicenseUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ライセンスユースケース
public final class LicenseUseCase {
    public static let s = LicenseUseCase()

    /// ロードリクエスト通知用RX
    public let rx_licenseUseCaseDidRequestOpen = PublishSubject<()>()

    private init() {}

    /// ライセンス表示
    public func open() {
        rx_licenseUseCaseDidRequestOpen.onNext(())
    }
}
