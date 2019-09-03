//
//  SelectFormUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class SelectFormUseCase {

    private var formDataModel: FormDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        formDataModel = FormDataModel.s
    }

    public func exe() -> [Form] {
        return formDataModel.select()
    }

    public func exe(id: String) -> [Form] {
        return formDataModel.select(id: id)
    }

    public func exe(url: String) -> [Form] {
        return formDataModel.select(url: url)
    }
}
