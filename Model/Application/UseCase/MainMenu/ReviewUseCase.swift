//
//  ReviewUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// レビューユースケース
public final class ReviewUseCase {
    public static let s = ReviewUseCase()

    /// ロードリクエスト通知用RX
    public let rx_reviewUseCaseDidRequestOpen = PublishSubject<()>()

    private init() {}

    /// ライセンス表示
    public func open() {
        rx_reviewUseCaseDidRequestOpen.onNext(())
    }
}
