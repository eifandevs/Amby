//
//  FetchFavoriteUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/24.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class FetchFavoriteUseCase {

    private var favoriteDataModel: FavoriteDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!

    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        favoriteDataModel = FavoriteDataModel.s
        userDataModel = UserDataModel.s
    }

    public func exe() -> Observable<()> {
        return Observable.create { [weak self] observable in
            guard let `self` = self, let uid = self.userDataModel.uid else {
                observable.onError(NSError.empty)
                return Disposables.create()
            }

            log.debug("fetch favorite start...")

            self.favoriteDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .fetch:
                        log.debug("fetch favorite success")
                        observable.onCompleted()
                    default: break
                    }
                }

            self.favoriteDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .fetch:
                        log.error("fetch favorite error")
                        observable.onError(NSError.empty)
                    default: break
                    }
                }
            .disposed(by: self.disposeBag)

            self.favoriteDataModel.fetch(request: GetFavoriteRequest(userId: uid))

            return Disposables.create()
       }
    }
}
