//
//  HelpUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ヘルプユースケース
final class HelpUseCase {

    static let s = HelpUseCase()

    /// ヘルプ画面表示通知用RX
    let rx_helpUseCaseDidRequestPresentHelpScreen = PublishSubject<(title: String, message: String)>()

    /// ヘルプ画面表示
    func open(title: String, message: String) {
        rx_helpUseCaseDidRequestPresentHelpScreen.onNext((title: title, message: message))
    }
}
