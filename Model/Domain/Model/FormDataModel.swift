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

    /// フォーム登録通知用RX
    let rx_formDataModelDidInsert = PublishSubject<()>()
    /// フォーム登録失敗通知用RX
    let rx_formDataModelDidInsertFailure = PublishSubject<()>()
    /// フォーム削除通知用RX
    let rx_formDataModelDidDelete = PublishSubject<()>()
    /// フォーム全削除通知用RX
    let rx_formDataModelDidDeleteAll = PublishSubject<()>()
    /// フォーム削除失敗通知用RX
    let rx_formDataModelDidDeleteFailure = PublishSubject<()>()
    /// フォーム情報取得失敗通知用RX
    let rx_formDataModelDidGetFailure = PublishSubject<()>()
    /// エラー通知用RX
    let rx_error = PublishSubject<FormDataModelError>()

    /// db repository
    let repository = DBRepository()

    private init() {}

    /// insert forms
    func insert(forms: [Form]) {
        let result = repository.insert(data: forms)

        switch result {
        case .success:
            rx_formDataModelDidInsert.onNext(())
        case .failure:
            rx_error.onNext(.store)
        }
    }

    /// select forms
    func select() -> [Form] {
        let result = repository.select(type: Form.self)

        switch result {
        case let .success(forms):
            return forms as! [Form]
        case .failure:
            rx_error.onNext(.get)
            return []
        }
    }

    func select(id: String) -> [Form] {
        let result = repository.select(type: Form.self)

        switch result {
        case let .success(forms):
            return (forms as! [Form]).filter({ $0.id == id })
        case .failure:
            rx_error.onNext(.get)
            return []
        }
    }

    func select(url: String) -> [Form] {
        let result = repository.select(type: Form.self)

        switch result {
        case let .success(forms):
            return (forms as! [Form]).filter({ $0.url == url })
        case .failure:
            rx_error.onNext(.get)
            return []
        }
    }

    /// delete forms
    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        let result = repository.delete(data: select())

        switch result {
        case .success:
            rx_formDataModelDidDeleteAll.onNext(())
        case .failure:
            rx_error.onNext(.delete)
        }
    }

    /// delete forms
    func delete(forms: [Form]) {
        let result = repository.delete(data: forms)

        switch result {
        case .success:
            rx_formDataModelDidDelete.onNext(())
        case .failure:
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
