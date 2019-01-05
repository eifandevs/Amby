//
//  ProgressDataModel.swift
//  Qas
//
//  Created by temma on 2017/12/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum ProgressDataModelAction {
    case updateProgress(progress: CGFloat)
    case updateText(text: String)
}

/// プログレスデータモデル
final class ProgressDataModel {
    /// アクション通知用RX
    let rx_action = PublishSubject<ProgressDataModelAction>()

    static let s = ProgressDataModel()
    let center = NotificationCenter.default

    // プログレス
    private var progress = 0.f

    // header text
    private var headerFieldText = ""

    private init() {}

    /// update header progress
    func updateProgress(progress: CGFloat) {
        self.progress = progress
        rx_action.onNext(.updateProgress(progress: progress))
    }

    /// update header field text
    func updateText(text: String) {
        if !text.isEmpty && text != headerFieldText {
            headerFieldText = text
            rx_action.onNext(.updateText(text: text))
        }
    }

    /// reload
    func reload() {
        if let url = PageHistoryDataModel.s.currentHistory?.url {
            if url != headerFieldText {
                headerFieldText = url
                rx_action.onNext(.updateText(text: url))
            }
        }
    }
}
