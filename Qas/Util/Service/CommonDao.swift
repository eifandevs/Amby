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
    private let realmEncryptionToken: String!
    let keychainServiceToken: String!
    let keychainIvToken: String!
    
    private init() {
        // キーチェーンからトークン取得
        realmEncryptionToken = KeyChainHelper.getToken(key: AppConst.keychainRealmToken)
        keychainServiceToken = KeyChainHelper.getToken(key: AppConst.keychainEncryptServiceToken)
        keychainIvToken = KeyChainHelper.getToken(key: AppConst.keychainEncryptIvToken)

        do {
            realm = try Realm(configuration: RealmHelper.realmConfiguration(realmEncryptionToken: realmEncryptionToken))
        } catch let error as NSError {
            log.error("Realm initialize error. description: \(error.description)")
            realm = nil
        }
    }

    func insert(data: [Object]) {
        try! realm.write {
            realm.add(data, update: true)
        }
    }
    
    func delete(data: [Object]) {
        try! realm.write {
            realm.delete(data)
        }
    }
    
    func select(type: Object.Type) -> [Object] {
        return realm.objects(type).map { $0 }
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
        delete(data: selectAllForm())
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
                            webView.evaluate(script: "document.forms[\(i)].elements.length") { [weak self] (object, error) in
                                guard let `self` = self else { return }
                                if ((object != nil) && (error == nil)) {
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
                                                            input.value = EncryptHelper.encrypt(serviceToken: self.keychainServiceToken, ivToken: self.keychainIvToken, value: value)!
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
            if form.inputs.count > 0 {
                // 入力済みのフォームが一つでもあれば保存する
                let savedForm = CommonDao.s.selectAllForm().filter({ (f) -> Bool in
                    return form.url.domainAndPath == f.url.domainAndPath
                }).first
                if let unwrappedSavedForm = savedForm {
                    // すでに登録済みの場合は、まず削除する
                    CommonDao.s.delete(data: [unwrappedSavedForm])
                }
                CommonDao.s.insert(data: [form])
                NotificationManager.presentNotification(message: "フォーム情報を登録しました")
            } else {
                NotificationManager.presentNotification(message: "フォーム情報の入力を確認できませんでした")
            }
        } else {
            NotificationManager.presentNotification(message: "ページ情報を取得できませんでした。")
        }
    }

// MARK: サムネイル取得
    func getThumbnailImage(context: String) -> UIImage? {
        let image = UIImage(contentsOfFile: AppConst.thumbnailUrl(folder: context).path)
        return image?.crop(w: Int(AppConst.thumbnailSize.width * 2), h: Int((AppConst.thumbnailSize.width * 2) * DeviceConst.aspectRate))
    }
    
    func getCaptureImage(context: String) -> UIImage? {
        return UIImage(contentsOfFile: AppConst.thumbnailUrl(folder: context).path)
    }
// MARK: キャッシュ管理
    /// 検索履歴の保存
    func storeSearchHistory(searchHistory: [SearchHistoryItem]) {
        if searchHistory.count > 0 {
            // searchHistoryを日付毎に分ける
            var searchHistoryByDate: [String: [SearchHistoryItem]] = [:]
            for item in searchHistory {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
                dateFormatter.dateFormat = "yyyyMMdd"
                let key = dateFormatter.string(from: item.date)
                if searchHistoryByDate[key] == nil {
                    searchHistoryByDate[key] = [item]
                } else {
                    searchHistoryByDate[key]?.append(item)
                }
            }
            
            for (key, value) in searchHistoryByDate {
                let searchHistoryUrl = AppConst.searchHistoryUrl(date: key)
                
                let saveData: [SearchHistoryItem] = { () -> [SearchHistoryItem] in
                    do {
                        let data = try Data(contentsOf: searchHistoryUrl)
                        let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [SearchHistoryItem]
                        let saveData: [SearchHistoryItem] = value + old
                        return saveData
                    } catch let error as NSError {
                        log.error("failed to read search history: \(error)")
                        return value
                    }
                }()
                
                let searchHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                do {
                    try searchHistoryData.write(to: searchHistoryUrl)
                    log.debug("store search history")
                } catch let error as NSError {
                    log.error("failed to write search history: \(error)")
                }
            }
        }
    }
    
    /// 閲覧履歴の保存
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
                        let saveData: [CommonHistoryItem] = value + old
                        return saveData
                    } catch let error as NSError {
                        log.error("failed to read common history: \(error)")
                        return value
                    }
                }()
                
                let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                do {
                    try commonHistoryData.write(to: commonHistoryUrl)
                    log.debug("store common history")
                } catch let error as NSError {
                    log.error("failed to write common history: \(error)")
                }
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
        Util.deleteFolder(path: AppConst.pageHistoryPath)
    }
    
    /// 検索履歴の検索
    func selectSearchHistory(title: String, readNum: Int) -> [SearchHistoryItem] {
        let manager = FileManager.default
        var readFiles: [String] = []
        var result: [SearchHistoryItem] = []
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.searchHistoryPath)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()
            
            if readFiles.count > 0 {
                let latestFiles = readFiles.prefix(readNum)
                var allSearchHistory: [SearchHistoryItem] = []
                latestFiles.forEach({ (keyStr: String) in
                    do {
                        let data = try Data(contentsOf: AppConst.searchHistoryUrl(date: keyStr))
                        let searchHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [SearchHistoryItem]
                        allSearchHistory = allSearchHistory + searchHistory
                    } catch let error as NSError {
                        log.error("failed to read search history. error: \(error.localizedDescription)")
                    }
                })
                let hitSearchHistory = allSearchHistory.filter({ (searchHistoryItem) -> Bool in
                    return searchHistoryItem.title.lowercased().contains(title.lowercased())
                })
                
                // 重複の削除
                hitSearchHistory.forEach({ (item) in
                    if result.count == 0 {
                        result.append(item)
                    } else {
                        let resultTitles: [String] = result.map({ (item) -> String in
                            return item.title
                        })
                        if !resultTitles.contains(item.title) {
                            result.append(item)
                        }
                    }
                })
            }
            
        } catch let error as NSError {
            log.error("failed to read search history. error: \(error.localizedDescription)")
        }
        return result
    }
    
    /// 閲覧履歴の削除
    func deleteSearchHistory() {
        let manager = FileManager.default
        var readFiles: [String] = []
        let saveTerm = Int(UserDefaults.standard.float(forKey: AppConst.searchHistorySaveTermKey))
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.searchHistoryPath)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()

            if readFiles.count > saveTerm {
                let deleteFiles = readFiles.suffix(from: saveTerm)
                deleteFiles.forEach({ (key) in
                    try! FileManager.default.removeItem(atPath: AppConst.searchHistoryFilePath(date: key))
                })
                log.debug("deleteSearchHistory: \(deleteFiles)")
            }

        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
    }

    /// 閲覧履歴の検索
    func selectCommonHistory(title: String, readNum: Int) -> [CommonHistoryItem] {
        let manager = FileManager.default
        var readFiles: [String] = []
        var result: [CommonHistoryItem] = []
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.commonHistoryPath)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()
            
            if readFiles.count > 0 {
                let latestFiles = readFiles.prefix(readNum)
                var allCommonHistory: [CommonHistoryItem] = []
                latestFiles.forEach({ (keyStr: String) in
                    do {
                        let data = try Data(contentsOf: AppConst.commonHistoryUrl(date: keyStr))
                        let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistoryItem]
                        allCommonHistory = allCommonHistory + commonHistory
                    } catch let error as NSError {
                        log.error("failed to read common history. error: \(error.localizedDescription)")
                    }
                })
                let hitCommonHistory = allCommonHistory.filter({ (commonHistoryItem) -> Bool in
                    return commonHistoryItem.title.lowercased().contains(title)
                })
                
                // 重複の削除
                hitCommonHistory.forEach({ (item) in
                    if result.count == 0 {
                        result.append(item)
                    } else {
                        let resultTitles: [String] = result.map({ (item) -> String in
                            return item.title
                        })
                        if !resultTitles.contains(item.title) {
                            result.append(item)
                        }
                    }
                })
            }
            
        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
        return result
    }
    
    /// 閲覧履歴の削除
    func deleteCommonHistory() {
        let manager = FileManager.default
        var readFiles: [String] = []
        let saveTerm = Int(UserDefaults.standard.integer(forKey: AppConst.historySaveTermKey))
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.commonHistoryPath)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()

            if readFiles.count > saveTerm {
                let deleteFiles = readFiles.suffix(from: saveTerm)
                deleteFiles.forEach({ (key) in
                    try! FileManager.default.removeItem(atPath: AppConst.commonHistoryFilePath(date: key))
                })
                log.debug("deleteCommonHistory: \(deleteFiles)")
            }

        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
    }

    /// 特定の閲覧履歴を削除する
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
                    log.debug("remove common history file. date: \(key)")
                }
            }
        }
    }
    
    /// 閲覧履歴を全て削除
    func deleteAllCommonHistory() {
        Util.deleteFolder(path: AppConst.commonHistoryPath)
        Util.createFolder(path: AppConst.commonHistoryPath)
    }

    /// 検索履歴を全て削除
    func deleteAllSearchHistory() {
        Util.deleteFolder(path: AppConst.searchHistoryPath)
        Util.createFolder(path: AppConst.searchHistoryPath)
    }

    /// UDデフォルト値登録
    func registerDefaultData() {
        UserDefaults.standard.register(defaults: [AppConst.locationIndexKey: 0,
                                                  AppConst.autoScrollIntervalKey: 0.06,
                                                  AppConst.historySaveTermKey: 90,
                                                  AppConst.searchHistorySaveTermKey: 90])
    }
}
