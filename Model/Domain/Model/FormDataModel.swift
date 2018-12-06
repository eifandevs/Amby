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
            return MessageConst.NOTIFICATION.GET_Form_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_Form_ERROR
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_Form_ERROR
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

    /// db repository
    let repository = DBRepository()

    private init() {}

    /// insert forms
    func insert(forms: [Form]) {
        if repository.insert(data: forms) {
            rx_formDataModelDidInsert.onNext(())
        } else {
            rx_formDataModelDidInsertFailure.onNext(())
        }
    }

    /// select forms
    func select() -> [Form] {
        if let form = repository.select(type: Form.self) as? [Form] {
            return form
        } else {
            log.error("fail to select form")
            return []
        }
    }

    func select(id: String) -> [Form] {
        if let form = repository.select(type: Form.self) as? [Form] {
            return form.filter({ $0.id == id })
        } else {
            log.error("fail to select form")
            return []
        }
    }

    func select(url: String) -> [Form] {
        if let form = repository.select(type: Form.self) as? [Form] {
            return form.filter({ $0.url == url })
        } else {
            log.error("fail to select form")
            return []
        }
    }

    func select(id: String? = nil, url: String? = nil) -> [Form] {
        if let forms = repository.select(type: Form.self) as? [Form] {
            if let id = id {
                return forms.filter({ $0.id == id })
            } else if let url = url {
                return forms.filter({ $0.url.domainAndPath == url.domainAndPath })
            }
            return forms
        } else {
            log.error("fail to select form")
            return []
        }
    }

    /// delete forms
    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        if repository.delete(data: select()) {
            rx_formDataModelDidDeleteAll.onNext(())
        } else {
            rx_formDataModelDidDeleteFailure.onNext(())
        }
    }

    /// delete forms
    func delete(forms: [Form]) {
        if repository.delete(data: forms) {
            rx_formDataModelDidDelete.onNext(())
        } else {
            rx_formDataModelDidDeleteFailure.onNext(())
        }
    }

    /// store form
    func store(form: Form) {
        // 有効なフォーム情報かを判定
        // 入力済みのフォームが一つでもあれば保存する
        if form.inputs.count > 0 {
            if let savedForm = FormDataModel.s.select(url: form.url).first {
                FormDataModel.s.delete(forms: [savedForm])
            }
            FormDataModel.s.insert(forms: [form])
        } else {
            rx_formDataModelDidGetFailure.onNext(())
        }
    }
}
