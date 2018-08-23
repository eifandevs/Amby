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
final class ReportUseCase {

    static let s = ReportUseCase()

    /// レポート画面表示通知用RX
    let rx_reportUseCaseDidRequestPresentReportScreen = PublishSubject<()>()

    /// レポート画面表示
    func open() {
        rx_reportUseCaseDidRequestPresentReportScreen.onNext(())
    }
}
