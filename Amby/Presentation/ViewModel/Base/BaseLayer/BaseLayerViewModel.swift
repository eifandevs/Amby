//
//  BaseLayerViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/10.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

enum BaseLayerViewModelAction {
    case finishGrep
}

final class BaseLayerViewModel {
    /// Observable自動解放
    let disposeBag = DisposeBag()

    /// アクション通知用RX
    public let rx_action = PublishSubject<BaseLayerViewModelAction>()

    /// ユースケース
    private let rebuildTabUseCase = RebuildTabUseCase()

    deinit {
        log.debug("deinit called.")
    }

    init() {
        setupRx()
    }

    func setupRx() {
        GrepHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .finish: self.rx_action.onNext(.finishGrep)
                default: break
                }
            }
            .disposed(by: disposeBag)
    }

    /// 画面構築
    func rebuild() {
        rebuildTabUseCase.exe()
    }

    /// 自動入力
    func autoFill() {
        FormHandlerUseCase.s.autoFill()
    }

    /// 前に移動(グレップ)
    func grepPrevious() {
        GrepHandlerUseCase.s.previous()
    }

    /// 次に移動(グレップ)
    func grepNext() {
        GrepHandlerUseCase.s.next()
    }

    /// baseViewControllerの状態取得
    var canAutoFill: Bool {
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let baseViewController = delegate.window?.rootViewController {
            if let baseViewController = baseViewController as? BaseViewController {
                return !baseViewController.isPresented
            } else {
                return false
            }
        }
        return false
    }
}
