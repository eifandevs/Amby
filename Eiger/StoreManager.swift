//
//  StoreManager.swift
//  one-hand-browsing
//
//  Created by user1 on 2016/07/19.
//  Copyright © 2016年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

final class StoreManager {
    static let shared = StoreManager()
    private let realm: Realm
    
    private init() {
        realm = try! Realm()
    }

    func insertWithRLMObjects(data: [Object]) {
        try! realm.write {
            realm.add(data)
        }
    }
    
    func deleteWithRLMObjects(data: [Object]) {
        try! realm.write {
            realm.delete(data)
        }
    }
    
    // Favorite
    func selectAllFavorite() -> [Favorite] {
        return realm.objects(Favorite.self).map { $0 }
    }
    
    // Form
    func selectAllForm() -> [Form] {
        return realm.objects(Form.self).map { $0 }
    }
    
    // Form
    // フォーム情報の保存
    func storeForm(webView: EGWebView) {
        if let title = webView.title, let host = webView.url?.host, let url = webView.url?.absoluteString {
            let form = Form()
            form.title = title
            form.host = host
            form.url = url
            
            webView.evaluate(script: "document.forms.length") { (object, error) in
                if ((object != nil) && (error == nil)) {
                    let formLength = Int((object as? NSNumber)!)
                    if formLength > 0 {
                        for i in 0...(formLength - 1) {
                            webView.evaluate(script: "document.forms[\(i)].elements.length") { (object, error) in
                                if ((object != nil) && (error == nil)) {
                                    let elementLength = Int((object as? NSNumber)!)
                                    for j in 0...elementLength {
                                        webView.evaluate(script: "document.forms[\(i)].elements[\(j)].type") { (object, error) in
                                            if ((object != nil) && (error == nil)) {
                                                let type = object as? String
                                                if ((type != "hidden") && (type != "submit") && (type != "checkbox")) {
                                                    let input = Input()
                                                    input.type = type!
                                                    input.formIndex = i
                                                    input.formInputIndex = j
                                                    webView.evaluate(script: "document.forms[\(i)].elements[\(j)].value") { (object, error) in
                                                        input.value = (object as? String)!
                                                    }
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
            
            // 有効なフォーム情報かを判定
            if ((form.inputs.count > 0) && (form.title != nil) && (form.url != nil) && (form.host != nil)) {
                for input in form.inputs {
                    if input.value.characters.count > 0 {
                        // 入力済みのフォームが一つでもあれば保存する
                        let savedForm = StoreManager.shared.selectAllForm().filter({ (f) -> Bool in
                            return form.url == f.url
                        }).first
                        if let unwrappedSavedForm = savedForm {
                            // すでに登録済みの場合は、まず削除する
                            StoreManager.shared.deleteWithRLMObjects(data: [unwrappedSavedForm])
                        }
                        StoreManager.shared.insertWithRLMObjects(data: [form])
                        Util.shared.presentWarning(title: "フォーム登録完了", message: "フォーム情報を登録しました。")
                        return
                    }
                }
                Util.shared.presentWarning(title: "登録エラー", message: "フォーム情報の入力を確認できませんでした。")
            } else {
                Util.shared.presentWarning(title: "登録エラー", message: "フォーム情報を取得できませんでした。")
            }
        } else {
            Util.shared.presentWarning(title: "登録エラー", message: "ページ情報を取得できませんでした。")
        }
    }
}
