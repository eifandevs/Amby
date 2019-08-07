//
//  ExpireCheckHistoryUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/07.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class ExpireCheckHistoryUseCase {

    private var commonHistoryDataModel: CommonHistoryDataModelProtocol!
    private var settingDataModel: SettingDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        commonHistoryDataModel = CommonHistoryDataModel.s
        settingDataModel = SettingDataModel.s
    }

    public func exe() {
        commonHistoryDataModel.expireCheck(historySaveCount: settingDataModel.commonHistorySaveCount)
    }
}
