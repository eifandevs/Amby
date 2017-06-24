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
    
    func selectFavorite(url: String) -> Favorite? {
        return StoreManager.shared.selectAllFavorite().filter({ (f) -> Bool in
            return url.domainAndPath == f.url.domainAndPath
        }).first
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
                    // 入力済みのフォームが一つでもあれば保存する
                    if input.value.characters.count > 0 {
                        let savedForm = StoreManager.shared.selectAllForm().filter({ (f) -> Bool in
                            return form.url?.domainAndPath == f.url?.domainAndPath
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
    
// MARK: キャッシュ管理
    func storeCommonHistory(commonHistory: [CommonHistoryItem]) {
        if commonHistory.count > 0 {
            // commonHistoryを日付毎に分ける
            var commonHistoryByDate: [String: [CommonHistoryItem]] = [:]
            for item in commonHistory {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
                dateFormatter.dateFormat = "yyyyMMdd"
                let key = dateFormatter.string(from: item.date)
                if commonHistoryByDate[key] == nil {
                    commonHistoryByDate[key] = [item]
                } else {
                    commonHistoryByDate[key]?.append(item)
                }
            }
            
            for (key, value) in commonHistoryByDate {
                let commonHistoryUrl = AppDataManager.shared.commonHistoryUrl(date: key)
                
                let saveData: [CommonHistoryItem] = { () -> [CommonHistoryItem] in
                    do {
                        let data = try Data(contentsOf: commonHistoryUrl)
                        let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistoryItem]
                        let saveData: [CommonHistoryItem] = old + value
                        return saveData
                    } catch let error as NSError {
                        log.error("failed to read: \(error)")
                        return value
                    }
                }()
                
                let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                do {
                    try commonHistoryData.write(to: commonHistoryUrl)
                    log.debug("store common history")
                } catch let error as NSError {
                    log.error("failed to write: \(error)")
                }
            }
        }
    }
    
    func storeEachHistory(eachHistory: [HistoryItem]) {
        if eachHistory.count > 0 {
            let eachHistoryData = NSKeyedArchiver.archivedData(withRootObject: eachHistory)
            do {
                try eachHistoryData.write(to: AppDataManager.shared.eachHistoryPath)
                log.debug("store each history")
            } catch let error as NSError {
                log.error("failed to write: \(error)")
            }
        }
    }
    
    /// 閲覧履歴、お気に入り、フォームデータを削除する
    /// [日付: [id, id, ...]]
    func deleteStoreData(deleteHistoryIds: [String: [String]]) {
        // 履歴
        for (key, value) in deleteHistoryIds {
            let commonHistoryUrl = AppDataManager.shared.commonHistoryUrl(date: key)
            let saveData: [CommonHistoryItem]? = { () -> [CommonHistoryItem]? in
                do {
                    let data = try Data(contentsOf: commonHistoryUrl)
                    let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistoryItem]
                    let saveData = old.filter({ (historyItem) -> Bool in
                        return !value.contains(historyItem._id)
                    })
                    return saveData
                } catch let error as NSError {
                    log.error("failed to read: \(error)")
                    return nil
                }
            }()
            
            if let saveData = saveData {
                if saveData.count > 0 {
                    let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                    do {
                        try commonHistoryData.write(to: commonHistoryUrl)
                        log.debug("store common history")
                    } catch let error as NSError {
                        log.error("failed to write: \(error)")
                    }
                } else {
                    try! FileManager.default.removeItem(atPath: AppDataManager.shared.commonHistoryFilePath(date: key))
                    log.debug("remove common history file")
                }
            }
        }
    }
}
