//
//  GetSuggestUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class GetSuggestUseCase {

    private var suggestDataModel: SuggestDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        suggestDataModel = SuggestDataModel.s
    }

    /// 取得
    public func exe(token: String) {
        suggestDataModel.get(token: token)
    }
}
