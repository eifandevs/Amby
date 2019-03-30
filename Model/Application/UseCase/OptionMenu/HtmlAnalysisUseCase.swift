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

public enum HtmlAnalysisUseCaseAction {
    case present(html: String)
    case analytics
}

/// レポートユースケース
public final class HtmlAnalysisUseCase {
    public static let s = HtmlAnalysisUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<HtmlAnalysisUseCaseAction>()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    /// HTML画面表示
    public func present(html: String) {
        rx_action.onNext(.present(html: html))
    }

    /// HTML解析
    public func analytics() {
        rx_action.onNext(.analytics)
    }
}
