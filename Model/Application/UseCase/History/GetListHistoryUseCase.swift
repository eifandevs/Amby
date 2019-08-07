//
//  GetListHistoryUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/06.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class GetListHistoryUseCase {

    private var commonHistoryDataModel: CommonHistoryDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        commonHistoryDataModel = CommonHistoryDataModel.s
    }

    public func exe() -> [String] {
        return commonHistoryDataModel.getList()
    }
}
