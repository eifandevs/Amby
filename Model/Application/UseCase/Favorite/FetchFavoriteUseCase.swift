//
//  FetchFavoriteUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/08/24.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxSwift

public final class FetchFavoriteUseCase {

    private var favoriteDataModel: FavoriteDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!
    private var fetchFavoriteDispose: Disposable?
    private var fetchFavoriteErrorDispose: Disposable?

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

            self.fetchFavoriteDispose = self.favoriteDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .fetch:
                        log.debug("fetch favorite success")
                        observable.onCompleted()
                        self.fetchFavoriteDispose!.dispose()
                    default: break
                    }
                }

            self.fetchFavoriteErrorDispose = self.favoriteDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .fetch:
                        log.error("fetch favorite error")
                        observable.onError(NSError.empty)
                        self.fetchFavoriteErrorDispose!.dispose()
                    default: break
                    }
                }

            self.favoriteDataModel.fetch(request: GetFavoriteRequest(userId: uid))

            return Disposables.create()
       }
    }
}
