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

public enum ProgressUseCaseAction {
    case updateProgress(progress: CGFloat)
    case updateText(text: String)
}

/// ヘッダーユースケース
public final class ProgressUseCase {
    public static let s = ProgressUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<ProgressUseCaseAction>()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        setupRx()
    }

    private func setupRx() {
        // プログレス監視
        Observable
            .merge([
                ProgressDataModel.s.rx_action
                    .flatMap { action -> Observable<CGFloat> in
                        if case let .updateProgress(progress) = action {
                            return Observable.just(progress)
                        } else {
                            return Observable.empty()
                        }
                    },
                NotificationCenter.default.rx.notification(.UIApplicationDidBecomeActive, object: nil).flatMap { _ in Observable.just(0) },
            ])
            .subscribe { [weak self] progress in
                guard let `self` = self else { return }

                if let progress = progress.element {
                    self.rx_action.onNext(.updateProgress(progress: progress))
                }
            }
            .disposed(by: disposeBag)

        // テキストフィールド監視
        ProgressDataModel.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self else { return }
                if let action = action.element, case let .updateText(text) = action {
                    self.rx_action.onNext(.updateText(text: text))
                }
            }
            .disposed(by: disposeBag)
    }

    public func updateProgress(progress: CGFloat) {
        ProgressDataModel.s.updateProgress(progress: progress)
    }

    /// reload ProgressDataModel
    public func reloadProgress() {
        ProgressDataModel.s.reload()
    }

    /// update text in ProgressDataModel
    public func updateText(text: String) {
        ProgressDataModel.s.updateText(text: text)
    }
}
