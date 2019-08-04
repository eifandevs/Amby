//
//  FormHandlerUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum FormHandlerUseCaseAction {
    case register
    case autoFill
    case load(url: String)
    case read(form: Form)
}

/// フォームユースケース
public final class FormHandlerUseCase {
    public static let s = FormHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<FormHandlerUseCaseAction>()

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

    public func delete() {
        formDataModel.delete()
    }

    public func read(id: String) {
        if let form = SelectFormUseCase().exe(id: id).first {
            rx_action.onNext(.read(form: form))
        }
    }

    public func delete(forms: [Form]) {
        formDataModel.delete(forms: forms)
    }
}
