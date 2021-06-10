//
//  PostTabUseCase.swift
//  Model
//
//  Created by tenma.i on 2020/01/21.
//  Copyright © 2020 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxSwift

public final class PostTabUseCase {

    private var tabDataModel: TabDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!
    private var postTabDispose: Disposable?
    private var postTabErrorDispose: Disposable?

    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
        userDataModel = UserDataModel.s
    }

    public func exe() -> Observable<()> {
        return Observable.create { [weak self] observable in
            guard let `self` = self, let uid = self.userDataModel.uid else {
                observable.onError(NSError.empty)
                return Disposables.create()
            }

            log.debug("post tab start...")

            self.postTabDispose = self.tabDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .post:
                        log.debug("post tab success")
                        observable.onCompleted()
                        self.postTabDispose!.dispose()
                    default: break
                    }
                }

            self.postTabErrorDispose = self.tabDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .post:
                        log.error("post tab error")
                        observable.onError(NSError.empty)
                        self.postTabErrorDispose!.dispose()
                    default: break
                    }
                }

            self.tabDataModel.post(request: PostTabRequest(userId: uid, tabGroupList: self.tabDataModel.tabGroupList))

            return Disposables.create()
       }
    }
}
