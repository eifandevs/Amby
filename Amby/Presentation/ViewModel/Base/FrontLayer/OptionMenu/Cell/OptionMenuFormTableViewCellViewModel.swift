//
//  OptionMenuFormTableViewCellViewModel.swift
//  Amby
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Model
import RxSwift

final class OptionMenuFormTableViewCellViewModel {
    var form: Form!
    let disposeBag = DisposeBag()

    /// 閲覧リクエスト
    func readForm(id: String) {
        ChallengeLocalAuthenticationUseCase().exe()
            .subscribe { [weak self] success in
                guard let `self` = self, let success = success.element else { return }
                if success {
                    FormHandlerUseCase.s.read(id: id)
                }

            }.disposed(by: disposeBag)
    }
}
