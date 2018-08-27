//
//  BaseLayerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

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
}
