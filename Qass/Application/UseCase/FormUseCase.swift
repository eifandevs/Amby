//
//  FormUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// フォームユースケース
final class FormUseCase {

    static let s = FormUseCase()

    /// フォーム登録通知用RX
    let rx_formUseCaseDidRequestRegisterForm = PublishSubject<()>()
    /// 自動入力通知用RX
    let rx_formUseCaseDidRequestAutoFill = PublishSubject<()>()
    /// ロードリクエスト通知用RX
    let rx_formUseCaseDidRequestLoad = PublishSubject<String>()

    private init() {}

    /// フォーム登録
    func registerForm() {
        rx_formUseCaseDidRequestRegisterForm.onNext(())
    }

    /// 自動入力
    func autoFill() {
        rx_formUseCaseDidRequestAutoFill.onNext(())
    }

    /// ロードリクエスト
    func load(url: String) {
        rx_formUseCaseDidRequestLoad.onNext(url)
    }

    func store(form: Form) {
        FormDataModel.s.store(form: form)
    }
}
