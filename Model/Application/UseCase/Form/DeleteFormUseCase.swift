//
//  DeleteFormUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class DeleteFormUseCase {

    private var formDataModel: FormDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        formDataModel = FormDataModel.s
    }

    public func exe() {
        formDataModel.delete()
    }

    public func exe(forms: [Form]) {
        formDataModel.delete(forms: forms)
    }
}
