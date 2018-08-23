//
//  ContactUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// コンタクトユースケース
final class ContactUseCase {

    static let s = ContactUseCase()

    /// コンタクト画面表示通知用RX
    let rx_operationUseCaseDidRequestPresentContactScreen = PublishSubject<()>()

    /// コンタクト画面表示
    func open() {
        rx_operationUseCaseDidRequestPresentContactScreen.onNext(())
    }
}
