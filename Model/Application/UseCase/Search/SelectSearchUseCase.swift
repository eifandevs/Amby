//
//  SelectSearchUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class SelectSearchUseCase {

    private var searchHistoryDataModel: SearchHistoryDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        searchHistoryDataModel = SearchHistoryDataModel.s
    }

    /// 検索履歴の検索
    /// 検索ワードと検索件数を指定する
    /// 指定ワードを含むかどうか
    public func exe(title: String, readNum: Int) -> [SearchHistory] {
        return searchHistoryDataModel.select(title: title, readNum: readNum)
    }
}
