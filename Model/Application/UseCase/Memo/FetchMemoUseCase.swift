//
//  FetchMemoUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/11/20.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class FetchMemoUseCase {

    private var memoDataModel: MemoDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!

    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        memoDataModel = MemoDataModel.s
        userDataModel = UserDataModel.s
    }

    public func exe() -> Observable<()> {
        return Observable.create { [weak self] observable in
            guard let `self` = self, let uid = self.userDataModel.uid else {
                observable.onError(NSError.empty)
                return Disposables.create()
            }

            log.debug("fetch memo start...")

            self.memoDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .fetch:
                        log.debug("fetch memo success")
                        observable.onCompleted()
                    default: break
                    }
                }

            self.memoDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .fetch:
                        log.error("fetch memo error")
                        observable.onError(NSError.empty)
                    default: break
                    }
                }
            .disposed(by: self.disposeBag)

            self.memoDataModel.fetch(request: GetMemoRequest(userId: uid))

            return Disposables.create()
       }
    }
}
