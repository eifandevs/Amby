//
//  PostFavoriteUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/12/25.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxSwift

public final class PostFavoriteUseCase {

    private var favoriteDataModel: FavoriteDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!
    private var postFavoriteDispose: Disposable?
    private var postFavoriteErrorDispose: Disposable?

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

            log.debug("post favorite start...")

            self.postFavoriteDispose = self.favoriteDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .post:
                        log.debug("post favorite success")
                        observable.onCompleted()
                        self.postFavoriteDispose!.dispose()
                    default: break
                    }
                }

            self.postFavoriteErrorDispose = self.favoriteDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .post:
                        log.error("post favorite error")
                        observable.onError(NSError.empty)
                        self.postFavoriteErrorDispose!.dispose()
                    default: break
                    }
                }

            self.favoriteDataModel.post(request: PostFavoriteRequest(userId: uid, favorites: self.favoriteDataModel.select()))

            return Disposables.create()
       }
    }
}
