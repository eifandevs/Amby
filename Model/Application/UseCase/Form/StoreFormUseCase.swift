//
//  StoreFormUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class StoreFormUseCase {

    private var formDataModel: FormDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        formDataModel = FormDataModel.s
    }

    public func exe(form: Form) {
        formDataModel.store(form: form)
    }
}
