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

    public func exe(uid: String) -> Single<()> {

        return Single<()>.create(subscribe: { [weak self] (observer) -> Disposable in
            guard let `self` = self else {
                observer(.error(NSError.empty))
                return Disposables.create()
            }

            log.debug("login start...")

            if self.userDataModel.hasUID {
                log.debug("has uid.")
            }

            let request = LoginRequest(userId: uid)
            self.userDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case let .post(userInfo):
                        log.debug("app login success: \(userInfo.userId)")
                        observer(.success(()))
                    }
                }

            self.userDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .post:
                        observer(.error(NSError.empty))
                    }
                }
            .disposed(by: self.disposeBag)

            self.userDataModel.post(request: request)

            return Disposables.create()
        })
    }
}
