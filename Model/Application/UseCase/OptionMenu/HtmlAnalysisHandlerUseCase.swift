//
//  AnalyticsUseCase.swift
//  Model
//
//  Created by tenma on 2019/03/17.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum HtmlAnalysisHandlerUseCaseAction {
    case analytics
}

/// レポートユースケース
public final class HtmlAnalysisHandlerUseCase {
    public static let s = HtmlAnalysisHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<HtmlAnalysisHandlerUseCaseAction>()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    /// HTML解析
    public func analytics() {
        rx_action.onNext(.analytics)
    }
}
