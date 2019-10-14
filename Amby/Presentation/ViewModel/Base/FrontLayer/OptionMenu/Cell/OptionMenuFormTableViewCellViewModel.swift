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
            .subscribe { result in
                guard let result = result.element else { return }
                if case .success = result {
                    FormHandlerUseCase.s.read(id: id)
                }

            }.disposed(by: disposeBag)
    }
}
