//
//  LoginUseCase.swift
//  Amby
//
//  Created by tenma.i on 2019/08/14.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class LoginUseCase {

    private var userDataModel: UserDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        userDataModel = UserDataModel.s
    }

    public func exe(userId: String) {
        let request = LoginRequest(userId: userId)

        userDataModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .post(userInfo):
                    log.debug("userInfo: \(userInfo)")
                }
            }

        userDataModel.post(request: request)
    }
}
