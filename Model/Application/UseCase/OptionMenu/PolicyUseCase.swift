//
//  PolicyUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ポリシーユースケース
public final class PolicyUseCase {
    public static let s = PolicyUseCase()

    /// オープンリクエスト通知用RX
    public let rx_policyUseCaseDidRequestOpen = PublishSubject<()>()

    private init() {}

    /// ライセンス表示
    public func open() {
        rx_policyUseCaseDidRequestOpen.onNext(())
    }
}
