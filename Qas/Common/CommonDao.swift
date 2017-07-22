//
//  CommonDao.swift
//  one-hand-browsing
//
//  Created by user1 on 2016/07/19.
//  Copyright © 2016年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Realm

final class CommonDao {
    static let s = CommonDao()
    private let realm: Realm!
    
    private init() {
        do {
            realm = try Realm(configuration: RealmHelper.realmConfiguration())
        } catch let error as NSError {
            log.error("Realm initialize error. description: \(error.description)")
            realm = nil
        }
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
    
    /// Favorite
    func selectAllFavorite() -> [Favorite] {
        return realm.objects(Favorite.self).map { $0 }
    }
    
    func selectFavorite(id: String = "", url: String = "") -> Favorite? {
        if !id.isEmpty {
            return CommonDao.s.selectAllFavorite().filter({ (f) -> Bool in
                return id == f.id
            }).first
        } else if !url.isEmpty {
            return CommonDao.s.selectAllFavorite().filter({ (f) -> Bool in
                return url.domainAndPath == f.url.domainAndPath
            }).first
        }
        return nil
    }
    
    func deleteAllFavorite() {
        deleteWithRLMObjects(data: selectAllFavorite())
    }
    
    /// Form
    func selectAllForm() -> [Form] {
        return realm.objects(Form.self).map { $0 }
    }
    
    func selectForm(id: String = "", url: String = "") -> Form? {
        if !id.isEmpty {
            return CommonDao.s.selectAllForm().filter({ (f) -> Bool in
                return id == f.id
            }).first
        } else if !url.isEmpty {
            return CommonDao.s.selectAllForm().filter({ (f) -> Bool in
                return url.domainAndPath == f.url.domainAndPath
            }).first
        }
        return nil
    }

    func deleteAllForm() {
        deleteWithRLMObjects(data: selectAllForm())
    }
    
    /// フォーム情報の保存
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
            if (form.inputs.count > 0) {
                for input in form.inputs {
                    // 入力済みのフォームが一つでもあれば保存する
                    if input.value.characters.count > 0 {
                        let savedForm = CommonDao.s.selectAllForm().filter({ (f) -> Bool in
                            return form.url.domainAndPath == f.url.domainAndPath
                        }).first
                        if let unwrappedSavedForm = savedForm {
                            // すでに登録済みの場合は、まず削除する
                            CommonDao.s.deleteWithRLMObjects(data: [unwrappedSavedForm])
                        }
                        CommonDao.s.insertWithRLMObjects(data: [form])
                        Util.presentWarning(title: "フォーム登録完了", message: "フォーム情報を登録しました。")
                        return
                    }
                }
                Util.presentWarning(title: "登録エラー", message: "フォーム情報の入力を確認できませんでした。")
            } else {
                Util.presentWarning(title: "登録エラー", message: "フォーム情報を取得できませんでした。")
            }
        } else {
            Util.presentWarning(title: "登録エラー", message: "ページ情報を取得できませんでした。")
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
                let commonHistoryUrl = AppConst.commonHistoryUrl(date: key)
                
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
                try eachHistoryData.write(to: AppConst.eachHistoryUrl)
                log.debug("store each history")
            } catch let error as NSError {
                log.error("failed to write: \(error)")
            }
        }
    }
    
    /// サムネイルデータの削除
    func deleteAllThumbnail() {
        Util.deleteFolder(path: AppConst.thumbnailBaseFolderPath)
        Util.createFolder(path: AppConst.thumbnailBaseFolderPath)
    }
    
    /// 表示中ページ情報の削除
    func deleteAllHistory() {
        Util.deleteFolder(path: AppConst.eachHistoryPath)
    }
    
    /// 閲覧履歴、お気に入り、フォームデータを削除する
    /// [日付: [id, id, ...]]
    func deleteCommonHistory(deleteHistoryIds: [String: [String]]) {
        // 履歴
        for (key, value) in deleteHistoryIds {
            let commonHistoryUrl = AppConst.commonHistoryUrl(date: key)
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
                    try! FileManager.default.removeItem(atPath: AppConst.commonHistoryFilePath(date: key))
                    log.debug("remove common history file")
                }
            }
        }
    }
    
    /// 閲覧履歴を全て削除
    func deleteAllCommonHistory() {
        Util.deleteFolder(path: AppConst.commonHistoryPath)
        Util.createFolder(path: AppConst.commonHistoryPath)
    }

    /// UDデフォルト値登録
    func registerDefaultData() {
        UserDefaults.standard.register(defaults: [AppConst.locationIndexKey: 0,
                                                  AppConst.autoScrollIntervalKey: 0.06])
    }
}
