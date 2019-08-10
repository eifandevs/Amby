//
//  GetNewsUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/11.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class GetNewsUseCase {

    private var articleDataModel: ArticleDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        articleDataModel = ArticleDataModel.s
    }

    public func exe() {
        articleDataModel.get()
    }
}
