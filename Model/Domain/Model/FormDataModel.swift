//
//  FormDataModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

enum FormDataModelAction {
    case insert
    case delete
    case deleteAll
}

enum FormDataModelError {
    case get
    case store
    case delete
}

extension FormDataModelError: ModelError {
    var message: String {
        switch self {
        case .get:
            return MessageConst.NOTIFICATION.GET_FORM_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_FORM_ERROR
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_FORM_ERROR
        }
    }
}

final class FormDataModel {
    static let s = FormDataModel()

    /// アクション通知用RX
    let rx_action = PublishSubject<FormDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<FormDataModelError>()

    /// db repository
    let repository = DBRepository()

    private init() {}

    /// insert forms
    func insert(forms: [Form]) {
        let result = repository.insert(data: forms)

        if case .success = result {
            rx_action.onNext(.insert)
        } else {
            rx_error.onNext(.store)
        }
    }

    /// select forms
    func select() -> [Form] {
        let result = repository.select(Form.self)

        if case let .success(forms) = result {
            return forms
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    func select(id: String) -> [Form] {
        let result = repository.select(Form.self)

        if case let .success(forms) = result {
            return forms.filter({ $0.id == id })
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    func select(url: String) -> [Form] {
        let result = repository.select(Form.self)

        if case let .success(forms) = result {
            return forms.filter({ $0.url == url })
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    /// delete forms
    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        let result = repository.delete(data: select())

        if case .success = result {
            rx_action.onNext(.deleteAll)
        } else {
            rx_error.onNext(.delete)
        }
    }

    /// delete forms
    func delete(forms: [Form]) {
        let result = repository.delete(data: forms)

        if case .success = result {
            rx_action.onNext(.delete)
        } else {
            rx_error.onNext(.delete)
        }
    }

    /// store form
    func store(form: Form) {
        // 有効なフォーム情報かを判定
        // 入力済みのフォームが一つでもあれば保存する
        if form.inputs.count > 0 {
            if let savedForm = select(url: form.url).first {
                delete(forms: [savedForm])
            }
            FormDataModel.s.insert(forms: [form])
        } else {
            rx_error.onNext(.store)
        }
    }
}
