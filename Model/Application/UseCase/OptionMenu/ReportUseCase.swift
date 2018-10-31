//
//  ReportUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// レポートユースケース
public final class ReportUseCase {
    public static let s = ReportUseCase()

    /// レポート画面表示通知用RX
    public let rx_reportUseCaseDidRequestOpen = PublishSubject<()>()

    /// 一覧表示通知用RX
    public let rx_reportUseCaseDidRequestLoad = PublishSubject<String>()

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
        rx_reportUseCaseDidRequestOpen.onNext(())
    }

    /// レポート一覧表示
    public func openList() {
        rx_reportUseCaseDidRequestLoad.onNext(ModelConst.URL.ISSUE_URL)
    }

    /// Issue登録
    public func registerReport(title: String, message: String) {
        IssueDataModel.s.post(title: title, body: message)
    }
}
