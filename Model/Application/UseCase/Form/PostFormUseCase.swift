//
//  PostFormUseCase.swift
//  Model
//
//  Created by tenma.i on 2020/01/09.
//  Copyright © 2020 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxSwift

public final class PostFormUseCase {

    private var formDataModel: FormDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!
    private var postFormDispose: Disposable?
    private var postFormErrorDispose: Disposable?

    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        formDataModel = FormDataModel.s
        userDataModel = UserDataModel.s
    }

    public func exe() -> Observable<()> {
        return Observable.create { [weak self] observable in
            guard let `self` = self, let uid = self.userDataModel.uid else {
                observable.onError(NSError.empty)
                return Disposables.create()
            }

            log.debug("post form start...")

            self.postFormDispose = self.formDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .post:
                        log.debug("post form success")
                        observable.onCompleted()
                        self.postFormDispose!.dispose()
                    default: break
                    }
                }

            self.postFormErrorDispose = self.formDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .post:
                        log.error("post form error")
                        observable.onError(NSError.empty)
                        self.postFormErrorDispose!.dispose()
                    default: break
                    }
                }

            self.formDataModel.post(request: PostFormRequest(userId: uid, forms: self.formDataModel.select()))

            return Disposables.create()
       }
    }
}
