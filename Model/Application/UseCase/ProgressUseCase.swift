//
//  ProgressUseCase.swift
//  Amby
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
    case updateCanGoBack(canGoBack: Bool)
    case updateCanGoForward(canGoForward: Bool)
}

/// ヘッダーユースケース
public final class ProgressUseCase {
    public static let s = ProgressUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<ProgressUseCaseAction>()

    private var currentContext: String {
        return tabDataModel.currentContext
    }

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private var tabDataModel: TabDataModelProtocol!
    private var progressDataModel: ProgressDataModelProtocol!

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
        progressDataModel = ProgressDataModel.s
    }

    private func setupRx() {
        // プログレス監視
        Observable
            .merge([
                progressDataModel.rx_action
                    .flatMap { action -> Observable<CGFloat> in
                        if case let .updateProgress(progress) = action {
                            return Observable.just(progress)
                        } else {
                            return Observable.empty()
                        }
                    },
                NotificationCenter.default.rx.notification(.UIApplicationDidBecomeActive, object: nil).flatMap { _ in Observable.just(0) }
            ])
            .subscribe { [weak self] progress in
                guard let `self` = self else { return }

                if let progress = progress.element {
                    self.rx_action.onNext(.updateProgress(progress: progress))
                }
            }
            .disposed(by: disposeBag)

        // テキストフィールド監視
        progressDataModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self else { return }
                if let action = action.element, case let .updateText(text) = action {
                    self.rx_action.onNext(.updateText(text: text))
                }
            }
            .disposed(by: disposeBag)
    }

    public func updateProgress(progress: CGFloat) {
        progressDataModel.updateProgress(progress: progress)
    }

    /// reload ProgressDataModel
    public func reloadProgress() {
        if let currentHistory = tabDataModel.currentHistory {
            progressDataModel.reload(currentHistory: currentHistory)
        }
    }

    /// update text in ProgressDataModel
    public func updateText(text: String) {
        progressDataModel.updateText(text: text)
    }

    /// update cangoback
    public func updateCanGoBack(context: String, canGoBack: Bool) {
        if context == currentContext {
            rx_action.onNext(.updateCanGoBack(canGoBack: canGoBack))
        }
    }

    /// update cangoforward
    public func updateCanGoForward(context: String, canGoForward: Bool) {
        if context == currentContext {
            rx_action.onNext(.updateCanGoForward(canGoForward: canGoForward))
        }
    }
}
