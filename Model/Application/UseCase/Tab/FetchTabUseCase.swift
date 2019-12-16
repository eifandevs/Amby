//
//  FetchTabUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/11/28.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class FetchTabUseCase {

    private var tabDataModel: TabDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!

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

            log.debug("fetch tab data start...")

            self.tabDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .fetch:
                        log.debug("fetch tab success")
                        observable.onCompleted()
                    default: break
                    }
                }
            .disposed(by: self.disposeBag)

            self.tabDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .fetch:
                        log.error("fetch tab error")
                        observable.onError(NSError.empty)
                    default: break
                    }
                }
            .disposed(by: self.disposeBag)

            self.tabDataModel.fetch(request: GetTabRequest(userId: uid))

            return Disposables.create()
       }
    }
}
