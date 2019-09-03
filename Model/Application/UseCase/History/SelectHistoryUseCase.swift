//
//  SelectHistoryUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/07.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class SelectHistoryUseCase {

    private var commonHistoryDataModel: CommonHistoryDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        commonHistoryDataModel = CommonHistoryDataModel.s
    }

    public func exe(dateString: String) -> [CommonHistory] {
        return commonHistoryDataModel.select(dateString: dateString)
    }

    /// 検索ワードと検索件数を指定する
    public func exe(title: String, readNum: Int) -> [CommonHistory] {
        return commonHistoryDataModel.select(title: title, readNum: readNum)
    }
}
