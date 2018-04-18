//
//  FormDataModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

final class FormDataModel {
    static let s = FormDataModel()

    /// DBプロバイダー
    let dbProvider = DBProvider()

    func insert(forms: [Form]) {
        dbProvider.insert(data: forms)
    }

    func select(id: String? = nil, url: String? = nil) -> [Form] {
        let forms = dbProvider.select(type: Form.self) as! [Form]
        if let id = id {
            return forms.filter({ $0.id == id })
        } else if let url = url {
            return forms.filter({ $0.url.domainAndPath == url.domainAndPath })
        }
        return forms
    }

    func delete(forms: [Form]? = nil) {
        if let forms = forms {
            dbProvider.delete(data: forms)
        } else {
            // 削除対象が指定されていない場合は、すべて削除する
            dbProvider.delete(data: select())
        }
    }

    /// フォーム情報の保存
    func store(form: Form) {
        // 有効なフォーム情報かを判定
        // 入力済みのフォームが一つでもあれば保存する
        if form.inputs.count > 0 {
            if let savedForm = FormDataModel.s.select(url: form.url).first {
                FormDataModel.s.delete(forms: [savedForm])
            }
            FormDataModel.s.insert(forms: [form])
            NotificationManager.presentNotification(message: MessageConst.NOTIFICATION_REGISTER_FORM)
        } else {
            NotificationManager.presentNotification(message: MessageConst.NOTIFICATION_REGISTER_FORM_ERROR_INPUT)
        }
    }
}
