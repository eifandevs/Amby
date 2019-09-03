//
//  ExpireCheckSearchUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class ExpireCheckSearchUseCase {

    private var searchHistoryDataModel: SearchHistoryDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        searchHistoryDataModel = SearchHistoryDataModel.s
    }

    public func exe() {
        searchHistoryDataModel.expireCheck()
    }
}
