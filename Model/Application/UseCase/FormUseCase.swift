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
public final class FormUseCase {
    public static let s = FormUseCase()

    /// フォーム登録通知用RX
    public let rx_formUseCaseDidRequestRegisterForm = PublishSubject<()>()
    /// 自動入力通知用RX
    public let rx_formUseCaseDidRequestAutoFill = PublishSubject<()>()
    /// ロードリクエスト通知用RX
    public let rx_formUseCaseDidRequestLoad = PublishSubject<String>()
    /// 閲覧通知用RX
    public let rx_formUseCaseDidRequestRead = PublishSubject<String>()

    private init() {}

    /// フォーム登録
    public func registerForm() {
        rx_formUseCaseDidRequestRegisterForm.onNext(())
    }

    /// 自動入力
    public func autoFill() {
        rx_formUseCaseDidRequestAutoFill.onNext(())
    }

    /// ロードリクエスト
    public func load(url: String) {
        rx_formUseCaseDidRequestLoad.onNext(url)
    }

    public func store(form: Form) {
        FormDataModel.s.store(form: form)
    }

    public func delete() {
        FormDataModel.s.delete()
    }

    public func read(id: String) {
        rx_formUseCaseDidRequestRead.onNext(id)
    }

    public func delete(forms: [Form]) {
        FormDataModel.s.delete(forms: forms)
    }

    public func select() -> [Form] {
        return FormDataModel.s.select()
    }

    public func select(id: String) -> [Form] {
        return FormDataModel.s.select(id: id)
    }

    public func select(url: String) -> [Form] {
        return FormDataModel.s.select(url: url)
    }
}
