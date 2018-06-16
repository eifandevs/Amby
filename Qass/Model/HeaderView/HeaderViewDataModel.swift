//
//  HeaderViewDataModel.swift
//  Qas
//
//  Created by temma on 2017/12/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ページ共通データモデル
final class HeaderViewDataModel {
    /// プログレス更新通知用RX
    let rx_headerViewDataModelDidUpdateProgress = PublishSubject<CGFloat>()
    /// ヘッダーテキストの更新通知用RX
    let rx_headerViewDataModelDidUpdateText = PublishSubject<String>()
    /// 編集開始通知用RX
    let rx_headerViewDataModelDidBeginEditing = PublishSubject<Bool>()

    static let s = HeaderViewDataModel()
    let center = NotificationCenter.default

    // プログレス
    private var progress = 0.f

    // header text
    private var headerFieldText = ""

    /// update header progress
    func updateProgress(progress: CGFloat) {
        self.progress = progress
        rx_headerViewDataModelDidUpdateProgress.onNext(progress)
    }

    /// update header field text
    func updateText(text: String) {
        headerFieldText = text
        rx_headerViewDataModelDidUpdateText.onNext(text)
    }

    /// begin header edit
    func beginEditing(forceEditFlg: Bool) {
        rx_headerViewDataModelDidBeginEditing.onNext(forceEditFlg)
    }
}
