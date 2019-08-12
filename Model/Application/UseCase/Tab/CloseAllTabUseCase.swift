//
//  CloseAllTabUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class CloseTabAllUseCase {

    private var tabDataModel: TabDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
    }

    /// 全てのタブをクローズ
    public func exe() {
        let histories = tabDataModel.histories
        histories.forEach { tab in
            self.tabDataModel.remove(context: tab.context)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.25))
        }
    }
}
