//
//  GetAccessTokenUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/10/25.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class GetAccessTokenUseCase {

    private var accessTokenDataModel: AccessTokenDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        accessTokenDataModel = AccessTokenDataModel.s
    }

    public func exe() -> Single<GetAccessTokenResponse.AccessToken> {
        log.debug("has not api token. will common login")
        return Single<GetAccessTokenResponse.AccessToken>.create(subscribe: { [weak self] (observer) -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            let request = GetAccessTokenRequest(authHeaderToken: ModelConst.KEY.API_AUTH_HEADER_TOKEN)
            self.accessTokenDataModel.rx_action
                .subscribe { action in
                    guard let action = action.element else { return }
                    switch action {
                    case let .fetch(accessToken):
                        observer(.success(accessToken))
                    }
                }
            .disposed(by: self.disposeBag)

            self.accessTokenDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .fetch:
                        observer(.error(NSError.empty))
                    }
                }
            .disposed(by: self.disposeBag)

            self.accessTokenDataModel.fetch(request: request)

            return Disposables.create()
        })
    }
}
