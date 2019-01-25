//
//  FormUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum FormUseCaseAction {
    case register
    case autoFill
    case load(url: String)
    case read(form: Form)
}

/// フォームユースケース
public final class FormUseCase {
    public static let s = FormUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<FormUseCaseAction>()

    /// models
    private var formDataModel: FormDataModelProtocol!

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        formDataModel = FormDataModel.s
    }

    /// フォーム登録
    public func registerForm() {
        rx_action.onNext(.register)
    }

    /// 自動入力
    public func autoFill() {
        rx_action.onNext(.autoFill)
    }

    /// ロードリクエスト
    public func load(url: String) {
        rx_action.onNext(.load(url: url))
    }

    public func store(form: Form) {
        formDataModel.store(form: form)
    }

    public func delete() {
        formDataModel.delete()
    }

    public func read(id: String) {
        if let form = FormUseCase.s.select(id: id).first {
            rx_action.onNext(.read(form: form))
        }
    }

    public func delete(forms: [Form]) {
        formDataModel.delete(forms: forms)
    }

    public func select() -> [Form] {
        return formDataModel.select()
    }

    public func select(id: String) -> [Form] {
        return formDataModel.select(id: id)
    }

    public func select(url: String) -> [Form] {
        return formDataModel.select(url: url)
    }
}
