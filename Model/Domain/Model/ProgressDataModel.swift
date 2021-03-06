//
//  ProgressDataModel.swift
//  Amby
//
//  Created by temma on 2017/12/07.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import CommonUtil
import Entity
import Foundation
import RxCocoa
import RxSwift

enum ProgressDataModelAction {
    case updateProgress(progress: CGFloat)
    case updateText(text: String)
}

protocol ProgressDataModelProtocol {
    var rx_action: PublishSubject<ProgressDataModelAction> { get }
    func updateProgress(progress: CGFloat)
    func updateText(text: String)
    func reload(currentTab: Tab)
}

/// プログレスデータモデル
final class ProgressDataModel: ProgressDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<ProgressDataModelAction>()

    static let s = ProgressDataModel()

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
    func reload(currentTab: Tab) {
        if currentTab.url != headerFieldText {
            headerFieldText = currentTab.url
            rx_action.onNext(.updateText(text: currentTab.url))
        }
    }
}
