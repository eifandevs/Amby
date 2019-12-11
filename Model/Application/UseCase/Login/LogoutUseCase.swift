//
//  LogoutUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/11/11.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class LogoutUseCase {

    private var userDataModel: UserDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        userDataModel = UserDataModel.s
    }

    public func exe() {
        userDataModel.logout()
    }
}
