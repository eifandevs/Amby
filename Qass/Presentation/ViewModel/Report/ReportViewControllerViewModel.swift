//
//  ReportViewControllerViewModel.swift
//  Qass
//
//  Created by tenma on 2018/10/07.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class ReportViewControllerViewModel {
    /// 一覧表示
    func openList() {
        ReportUseCase.s.openList()
    }

    /// 送信
    func send(title: String, message: String) {
        let lastReportDate = SettingUseCase.s.lastReportDate
        let intervalHour = -(lastReportDate.timeIntervalSinceNow / 60 / 60)
        if intervalHour > Double(24) {
            // 前回投稿より24h経過していた場合に送信する
            SettingUseCase.s.lastReportDate = Date()
            ReportUseCase.s.registerReport(title: title, message: message)
        } else {
            log.warning("already reported")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationManager.presentToastNotification(message: MessageConst.NOTIFICATION.REGISTER_REPORT_MULTIPLE_ERROR, isSuccess: false)
            }
        }
    }
}
