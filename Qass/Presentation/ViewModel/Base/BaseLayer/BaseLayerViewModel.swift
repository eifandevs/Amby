//
//  BaseLayerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model

final class BaseLayerViewModel {
    deinit {
        log.debug("deinit called.")
    }

    /// 自動入力
    func autoFill() {
        FormUseCase.s.autoFill()
    }

    func store() {
        HistoryUseCase.s.store()
        TabUseCase.s.store()
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
