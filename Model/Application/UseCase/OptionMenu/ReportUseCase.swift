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
    public let rx_reportUseCaseDidRequestPresentReportScreen = PublishSubject<()>()

    /// 一覧表示通知用RX
    public let rx_reportUseCaseDidRequestOpen = PublishSubject<String>()

    /// レポート登録成功
    public let rx_reportUseCaseDidRegisterSuccess = IssueDataModel.s.rx_issueDataModelDidRegisterSuccess.flatMap { _ in Observable.just(()) }

    /// レポート登録失敗
    public let rx_reportUseCaseDidRegisterFailure = IssueDataModel.s.rx_issueDataModelDidRegisterFailure
        .flatMap { error -> Observable<Error?> in
            return Observable.just(error)
        }

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
        rx_reportUseCaseDidRequestPresentReportScreen.onNext(())
    }

    /// レポート一覧表示
    public func openList() {
        rx_reportUseCaseDidRequestOpen.onNext(ModelConst.URL.ISSUE_URL)
    }

    /// Issue登録
    public func registerReport(title: String, message: String) {
        IssueDataModel.s.post(title: title, body: message)
    }
}
