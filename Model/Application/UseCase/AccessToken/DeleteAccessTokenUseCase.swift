//
//  DeleteAccessTokenUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/10/31.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class DeleteAccessTokenUseCase {

    private var accessTokenDataModel: AccessTokenDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        accessTokenDataModel = AccessTokenDataModel.s
    }

    public func exe() {
        accessTokenDataModel.delete()
    }
}
