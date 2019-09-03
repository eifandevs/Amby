//
//  InsertHistoryUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/07.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class InsertHistoryUseCase {

    private var commonHistoryDataModel: CommonHistoryDataModelProtocol!
    private var tabDataModel: TabDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        commonHistoryDataModel = CommonHistoryDataModel.s
        tabDataModel = TabDataModel.s
    }

    public func exe(url: URL?, title: String?) {
        // プライベートモードの場合は保存しない
        if tabDataModel.isPrivate {
            log.debug("common history will not insert. ")
        } else {
            commonHistoryDataModel.insert(url: url, title: title)
        }
    }
}
