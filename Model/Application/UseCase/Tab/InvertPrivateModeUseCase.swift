//
//  AddGroupUsecase.swift
//  Model
//
//  Created by iori tenma on 2019/08/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class InvertPrivateModeUseCase {

    private var tabDataModel: TabDataModelProtocol!
    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
    }

    /// change private mode
    public func exe(groupContext: String) {
        ChallengeLocalAuthenticationUseCase().exe()
            .subscribe(onNext: nil, onError: { _ in
                LocalAuthenticationHandlerUseCase.s.noticeInputError()
            }, onCompleted: {
                self.tabDataModel.invertPrivateMode(groupContext: groupContext)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
