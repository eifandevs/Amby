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
public final class ContactUseCase {
    public static let s = ContactUseCase()

    /// コンタクト画面表示通知用RX
    public let rx_operationUseCaseDidRequestPresentContactScreen = PublishSubject<()>()

    private init() {}

    /// コンタクト画面表示
    public func open() {
        rx_operationUseCaseDidRequestPresentContactScreen.onNext(())
    }
}
