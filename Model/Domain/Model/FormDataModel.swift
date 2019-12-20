//
//  FormDataModel.swift
//  Amby
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

enum FormDataModelAction {
    case insert
    case delete
    case deleteAll
    case fetch(forms: [Form])
}

enum FormDataModelError {
    case fetch
    case get
    case store
    case delete
}

extension FormDataModelError: ModelError {
    var message: String {
        switch self {
        case .fetch:
            return MessageConst.NOTIFICATION.GET_FORM_ERROR
        case .get:
            return MessageConst.NOTIFICATION.GET_FORM_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_FORM_ERROR
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_FORM_ERROR
        }
    }
}

protocol FormDataModelProtocol {
    var rx_action: PublishSubject<FormDataModelAction> { get }
    var rx_error: PublishSubject<FormDataModelError> { get }
    func insert(forms: [Form])
    func select() -> [Form]
    func select(id: String) -> [Form]
    func select(url: String) -> [Form]
    func delete()
    func delete(forms: [Form])
    func store(form: Form)
    func fetch(request: GetFormRequest)
}

final class FormDataModel: FormDataModelProtocol {
    static let s = FormDataModel()

    /// アクション通知用RX
    let rx_action = PublishSubject<FormDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<FormDataModelError>()

    /// 更新有無フラグ(更新されていればサーバーと同期する)
    var isUpdated = false
    
    /// db repository
    private let repository = DBRepository()

    private let disposeBag = DisposeBag()

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

    func fetch(request: GetFormRequest) {
        let repository = ApiRepository<App>()

        repository.rx.request(.getForm(request: request))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> GetFormResponse? in

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let formResponse: GetFormResponse = try decoder.decode(GetFormResponse.self, from: response.data)
                    return formResponse
                } catch {
                    return nil
                }
            }
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let `self` = self else { return }
                    if let response = response, response.code == ModelConst.APP_STATUS_CODE.NORMAL {
                        log.debug("get form success.")
                        let forms = response.data.map {$0}
                        // initialize data
                        _ = self.repository.delete(data: self.select())
                        _ = self.repository.insert(data: forms)
                        self.rx_action.onNext(.fetch(forms: forms))
                    } else {
                        log.error("get form error. code: \(response?.code ?? "")")
                        self.rx_error.onNext(.fetch)
                    }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    log.error("get form error. error: \(error.localizedDescription)")
                    self.rx_error.onNext(.fetch)
            })
            .disposed(by: disposeBag)
    }
}
