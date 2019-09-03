//
//  ReloadProgressUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class ReloadProgressUseCase {

    private var tabDataModel: TabDataModelProtocol!
    private var progressDataModel: ProgressDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
        progressDataModel = ProgressDataModel.s
    }

    /// reload ProgressDataModel
    public func exe() {
        if let currentTab = tabDataModel.currentTab {
            progressDataModel.reload(currentTab: currentTab)
        }
    }
}
