//
//  ProgressUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ヘッダーユースケース
final class ProgressUseCase {
    static let s = ProgressUseCase()

    /// プログレス更新通知用RX
    let rx_progressUseCaseDidChangeProgress = Observable
        .merge([
            ProgressDataModel.s.rx_progressDataModelDidUpdateProgress,
            NotificationCenter.default.rx.notification(.UIApplicationDidBecomeActive, object: nil).flatMap { _ in Observable.just(0) }
        ])
        .flatMap { progress -> Observable<CGFloat> in
            return Observable.just(progress)
        }

    /// テキストフィールド更新通知用RX
    let rx_progressUseCaseDidChangeField = ProgressDataModel.s.rx_progressDataModelDidUpdateText
        .flatMap { text -> Observable<String> in
            return Observable.just(text)
        }

    private init() {}

    func updateProgress(progress: CGFloat) {
        ProgressDataModel.s.updateProgress(progress: progress)
    }

    /// reload ProgressDataModel
    func reloadProgress() {
        ProgressDataModel.s.reload()
    }

    /// update text in ProgressDataModel
    func updateText(text: String) {
        ProgressDataModel.s.updateText(text: text)
    }
}
