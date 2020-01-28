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
    private var loginDispose: Disposable?
    private var loginErrorDispose: Disposable?

    public var isLoggedIn: Bool {
        userDataModel.hasUID
    }
    /// Observable自動解放
    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        userDataModel = UserDataModel.s
    }

    public func exe(uid: String) {
        log.debug("app login start...")
        let request = LoginRequest(userId: uid)
        userDataModel.post(request: request)
    }

    public func exe(uid: String) -> Observable<()> {

        return Observable.create { [weak self] observable in
            guard let `self` = self else {
                observable.onError(NSError.empty)
                return Disposables.create()
            }

            log.debug("app login start...")

            if self.userDataModel.hasUID {
                log.debug("has uid.")
            }

            let request = LoginRequest(userId: uid)
            self.loginDispose = self.userDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case let .post(userInfo):
                        log.debug("app login success: \(userInfo.userId)")
                        observable.onCompleted()
                        self.loginDispose!.dispose()
                    }
                }

            self.loginErrorDispose = self.userDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .post:
                        observable.onError(NSError.empty)
                        self.loginErrorDispose!.dispose()
                    }
                }

            self.userDataModel.post(request: request)
            return Disposables.create()
        }
    }
}
