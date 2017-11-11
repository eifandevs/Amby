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
    let realmEncryptionToken: String!
    let keychainServiceToken: String!
    let keychainIvToken: String!
    
    private init() {
        // キーチェーンからトークン取得
        realmEncryptionToken = KeyChainHelper.getToken(key: AppConst.KEY_REALM_TOKEN)
        keychainServiceToken = KeyChainHelper.getToken(key: AppConst.KEY_ENCRYPT_SERVICE_TOKEN)
        keychainIvToken = KeyChainHelper.getToken(key: AppConst.KEY_ENCRYPT_IV_TOKEN)

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

// MARK: サムネイル取得
    func getThumbnailImage(context: String) -> UIImage? {
        let image = UIImage(contentsOfFile: Util.thumbnailUrl(folder: context).path)
        return image?.crop(w: Int(AppConst.BASE_LAYER_THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER_THUMBNAIL_SIZE.width * 2) * DeviceConst.ASPECT_RATE))
    }
    
    func getCaptureImage(context: String) -> UIImage? {
        return UIImage(contentsOfFile: Util.thumbnailUrl(folder: context).path)
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
                let searchHistoryUrl = Util.searchHistoryUrl(date: key)
                
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

    /// サムネイルデータの削除
    func deleteAllThumbnail() {
        Util.deleteFolder(path: AppConst.PATH_THUMBNAIL)
        Util.createFolder(path: AppConst.PATH_THUMBNAIL)
    }
    
    /// 検索履歴の検索
    func selectSearchHistory(title: String, readNum: Int) -> [SearchHistoryItem] {
        let manager = FileManager.default
        var readFiles: [String] = []
        var result: [SearchHistoryItem] = []
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.PATH_SEARCH_HISTORY)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()
            
            if readFiles.count > 0 {
                let latestFiles = readFiles.prefix(readNum)
                var allSearchHistory: [SearchHistoryItem] = []
                latestFiles.forEach({ (keyStr: String) in
                    do {
                        let data = try Data(contentsOf: Util.searchHistoryUrl(date: keyStr))
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
        let saveTerm = Int(UserDefaults.standard.float(forKey: AppConst.KEY_SEARCH_HISTORY_SAVE_TERM))
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.PATH_SEARCH_HISTORY)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()

            if readFiles.count > saveTerm {
                let deleteFiles = readFiles.suffix(from: saveTerm)
                deleteFiles.forEach({ (key) in
                    try! FileManager.default.removeItem(atPath: Util.searchHistoryPath(date: key))
                })
                log.debug("deleteSearchHistory: \(deleteFiles)")
            }

        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
    }
    
    /// 検索履歴を全て削除
    func deleteAllSearchHistory() {
        Util.deleteFolder(path: AppConst.PATH_SEARCH_HISTORY)
        Util.createFolder(path: AppConst.PATH_SEARCH_HISTORY)
    }

    /// UDデフォルト値登録
    func registerDefaultData() {
        UserDefaults.standard.register(defaults: [AppConst.KEY_LOCATION_INDEX: 0,
                                                  AppConst.KEY_AUTO_SCROLL_INTERVAL: 0.06,
                                                  AppConst.KEY_HISTORY_SAVE_TERM: 90,
                                                  AppConst.KEY_SEARCH_HISTORY_SAVE_TERM: 90])
    }
}
