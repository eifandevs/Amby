//
//  ReportUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum ReportUseCaseAction {
    case present
    case load(url: String)
}

/// レポートユースケース
public final class ReportUseCase {
    public static let s = ReportUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<ReportUseCaseAction>()

    /// 最終お問い合わせ日
    public var lastReportDate: Date {
        get {
            return SettingDataModel.s.lastReportDate
        }
        set(value) {
            SettingDataModel.s.lastReportDate = value
        }
    }

    private init() {}

    /// レポート画面表示
    public func open() {
        rx_action.onNext(.present)
    }

    /// レポート一覧表示
    public func openList() {
        rx_action.onNext(.load(url: ModelConst.URL.ISSUE_URL))
    }

    /// Issue登録
    public func registerReport(title: String, message: String) {
        IssueDataModel.s.post(title: title, body: message)
    }
}
