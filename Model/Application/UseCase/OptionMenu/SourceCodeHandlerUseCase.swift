//
//  SourceCodeHandlerUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum SourceCodeHandlerUseCaseAction {
    case load(url: String)
}

/// ソースコードユースケース
public final class SourceCodeHandlerUseCase {
    public static let s = SourceCodeHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<SourceCodeHandlerUseCaseAction>()

    private init() {}

    /// ソースコードページ表示
    public func open() {
        rx_action.onNext(.load(url: ModelConst.URL.SOURCE_URL))
    }
}
