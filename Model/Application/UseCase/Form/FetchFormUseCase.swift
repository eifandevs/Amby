//
//  FetchFormUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/12/06.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class FetchFormUseCase {

    private var formDataModel: FormDataModelProtocol!
    private var userDataModel: UserDataModelProtocol!

    private var fetchFormDispose: Disposable?
    private var fetchFormErrorDispose: Disposable?
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

            log.debug("fetch form start...")

            self.fetchFormDispose = self.formDataModel.rx_action
                .subscribe { [weak self] action in
                    guard let `self` = self, let action = action.element else { return }
                    switch action {
                    case .fetch:
                        log.debug("fetch form success")
                        observable.onCompleted()
                        self.fetchFormDispose!.dispose()
                    default: break
                    }
                }

            self.fetchFormErrorDispose = self.formDataModel.rx_error
                .subscribe { error in
                    guard let error = error.element else { return }
                    switch error {
                    case .fetch:
                        log.error("fetch form error")
                        observable.onError(NSError.empty)
                        self.fetchFormErrorDispose!.dispose()
                    default: break
                    }
                }

            self.formDataModel.fetch(request: GetFormRequest(userId: uid))

            return Disposables.create()
       }
    }
}
