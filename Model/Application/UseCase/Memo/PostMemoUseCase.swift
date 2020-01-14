//
//  PostMemoUseCase.swift
//  Model
//
//  Created by tenma.i on 2020/01/14.
//  Copyright © 2020 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxSwift

public final class PostMemoUseCase {

    private var memoDataModel: MemoDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!
    private var postMemoDispose: Disposable?
    private var postMemoErrorDispose: Disposable?

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

            log.debug("post memo start...")

            self.postMemoDispose = self.memoDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .post:
                        log.debug("post memo success")
                        observable.onCompleted()
                        self.postMemoDispose!.dispose()
                    default: break
                    }
                }

            self.postMemoErrorDispose = self.memoDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .post:
                        log.error("post memo error")
                        observable.onError(NSError.empty)
                        self.postMemoErrorDispose!.dispose()
                    default: break
                    }
                }

            self.memoDataModel.post(request: PostMemoRequest(userId: uid, memos: self.memoDataModel.select()))

            return Disposables.create()
       }
    }
}
