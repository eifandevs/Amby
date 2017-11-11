//
//  SearchHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

final class SearchHistoryDataModel {
    static let s = SearchHistoryDataModel()
    var histories = [SearchHistory]()
    
    /// 検索履歴の保存
    func store(histories: [SearchHistory]) {
        if histories.count > 0 {
            // searchHistoryを日付毎に分ける
            var searchHistoryByDate: [String: [SearchHistory]] = [:]
            for item in histories {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
                dateFormatter.dateFormat = AppConst.DATE_FORMAT
                let key = dateFormatter.string(from: item.date)
                if searchHistoryByDate[key] == nil {
                    searchHistoryByDate[key] = [item]
                } else {
                    searchHistoryByDate[key]?.append(item)
                }
            }
            
            for (key, value) in searchHistoryByDate {
                let searchHistoryUrl = Util.searchHistoryUrl(date: key)
                
                let saveData: [SearchHistory] = { () -> [SearchHistory] in
                    do {
                        let data = try Data(contentsOf: searchHistoryUrl)
                        let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [SearchHistory]
                        let saveData: [SearchHistory] = value + old
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
    
    /// 検索履歴の検索
    /// 検索ワードと検索件数を指定する
    func select(title: String, readNum: Int) -> [SearchHistory] {
        let manager = FileManager.default
        var readFiles: [String] = []
        var result: [SearchHistory] = []
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.PATH_SEARCH_HISTORY)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()
            
            if readFiles.count > 0 {
                let latestFiles = readFiles.prefix(readNum)
                var allSearchHistory: [SearchHistory] = []
                latestFiles.forEach({ (keyStr: String) in
                    do {
                        let data = try Data(contentsOf: Util.searchHistoryUrl(date: keyStr))
                        let searchHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [SearchHistory]
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
        histories = result
        return result
    }
    
    /// 閲覧履歴の期限切れ削除
    func expireCheck() {
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
    func delete() {
        Util.deleteFolder(path: AppConst.PATH_SEARCH_HISTORY)
        Util.createFolder(path: AppConst.PATH_SEARCH_HISTORY)
    }
}

class SearchHistory: NSObject, NSCoding {
    var _id: String = NSUUID().uuidString
    var title: String = ""
    var date: Date = Date()
    
    override init() {
        super.init()
    }
    
    init(_id: String = NSUUID().uuidString, title: String, date: Date) {
        self._id = _id
        self.title = title
        self.date = date
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let _id = decoder.decodeObject(forKey: "_id") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let date = decoder.decodeObject(forKey: "date") as! Date
        self.init(_id: _id, title: title, date: date)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
    }
}
