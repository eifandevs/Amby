//
//  DeleteHistoryUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/07.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class DeleteHistoryUseCase {

    private var commonHistoryDataModel: CommonHistoryDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        commonHistoryDataModel = CommonHistoryDataModel.s
    }

    public func exe() {
        commonHistoryDataModel.delete()
    }

    public func exe(historyIds: [String: [String]]) {
        commonHistoryDataModel.delete(historyIds: historyIds)
    }
}
