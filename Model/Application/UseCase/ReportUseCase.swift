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

    private init() {}

    /// レポート画面表示
    public func open() {
        rx_reportUseCaseDidRequestPresentReportScreen.onNext(())
    }
}
