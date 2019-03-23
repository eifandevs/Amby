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
    case analytics(url: String)
}

enum HtmlAnalysisUseCaseError {
    case notExistUrl
}

extension HtmlAnalysisUseCaseError: ModelError {
    var message: String {
        switch self {
        case .notExistUrl:
            return MessageConst.NOTIFICATION.HTML_ANALYSIS_NOT_EXIST_URL
        }
    }
}

/// レポートユースケース
public final class HtmlAnalysisUseCase {
    public static let s = HtmlAnalysisUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<HtmlAnalysisUseCaseAction>()

    /// エラー通知用RX
    let rx_error = PublishSubject<HtmlAnalysisUseCaseError>()

    // models
    private var pageHistoryDataModel: PageHistoryDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        pageHistoryDataModel = PageHistoryDataModel.s
    }

    /// HTML画面表示
    public func present(html: String) {
        log.debug("analytics html. html: \(html)")
        rx_action.onNext(.present(html: html))
    }

    /// HTML解析
    public func analytics() {
        if let currentHistory = pageHistoryDataModel.currentHistory {
            rx_action.onNext(.analytics(url: currentHistory.url))
        } else {
            rx_error.onNext(.notExistUrl)
        }
    }
}
