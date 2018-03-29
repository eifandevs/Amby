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

    func insert(forms: [Form]) {
        CommonDao.s.insert(data: forms)
    }
    
    func select(id: String? = nil, url: String? = nil) -> [Form] {
        let forms = CommonDao.s.select(type: Form.self) as! [Form]
        if let id = id {
            return forms.filter({ $0.id == id })
        } else if let url = url {
            return forms.filter({ $0.url.domainAndPath == url.domainAndPath })
        }
        return forms
    }
    
    func delete(forms: [Form]? = nil) {
        if let forms = forms {
            CommonDao.s.delete(data: forms)
        } else {
            // 削除対象が指定されていない場合は、すべて削除する
            CommonDao.s.delete(data: select())
        }
    }
    /// フォーム情報の保存
    func store(webView: EGWebView) {
        if let title = webView.title, let host = webView.url?.host, let url = webView.url?.absoluteString {
            let form = Form()
            form.title = title
            form.host = host
            form.url = url
            
            webView.evaluate(script: "document.forms.length") { (object, error) in
                if object != nil && error == nil {
                    let formLength = Int((object as? NSNumber)!)
                    if formLength > 0 {
                        for i in 0...(formLength - 1) {
                            webView.evaluate(script: "document.forms[\(i)].elements.length") { (object, error) in
                                if (object != nil) && (error == nil) {
                                    let elementLength = Int((object as? NSNumber)!)
                                    for j in 0...elementLength {
                                        webView.evaluate(script: "document.forms[\(i)].elements[\(j)].type") { (object, error) in
                                            if ((object != nil) && (error == nil)) {
                                                let type = object as? String
                                                if ((type != "hidden") && (type != "submit") && (type != "checkbox")) {
                                                    let input = Input()
                                                    webView.evaluate(script: "document.forms[\(i)].elements[\(j)].value") { (object, error) in
                                                        let value = object as! String
                                                        if value.characters.count > 0 {
                                                            input.type = type!
                                                            input.formIndex = i
                                                            input.formInputIndex = j
                                                            input.value = EncryptHelper.encrypt(serviceToken: CommonDao.s.keychainServiceToken, ivToken: CommonDao.s.keychainIvToken, value: value)!
                                                            form.inputs.append(input)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
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
        } else {
            NotificationManager.presentNotification(message: MessageConst.NOTIFICATION_REGISTER_FORM_ERROR_CRAWL)
        }
    }
}
