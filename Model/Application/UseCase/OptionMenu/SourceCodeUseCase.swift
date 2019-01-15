//
//  SourceCodeUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum SourceCodeUseCaseAction {
    case load(url: String)
}

/// ソースコードユースケース
public final class SourceCodeUseCase {
    public static let s = SourceCodeUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<SourceCodeUseCaseAction>()

    private init() {}

    /// ソースコードページ表示
    public func open() {
        rx_action.onNext(.load(url: ModelConst.URL.SOURCE_URL))
    }
}
