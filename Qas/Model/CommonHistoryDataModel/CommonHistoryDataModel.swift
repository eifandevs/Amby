//
//  CommonHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class CommonHistoryDataModel {

    /// 閲覧履歴の保存
    func storeCommonHistory(commonHistory: [CommonHistory]) {
        if commonHistory.count > 0 {
            // commonHistoryを日付毎に分ける
            var commonHistoryByDate: [String: [CommonHistory]] = [:]
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
                
                let saveData: [CommonHistory] = { () -> [CommonHistory] in
                    do {
                        let data = try Data(contentsOf: commonHistoryUrl)
                        let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
                        let saveData: [CommonHistory] = value + old
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

    /// 閲覧履歴の検索
    func selectCommonHistory(title: String, readNum: Int) -> [CommonHistory] {
        let manager = FileManager.default
        var readFiles: [String] = []
        var result: [CommonHistory] = []
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.commonHistoryPath)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()
            
            if readFiles.count > 0 {
                let latestFiles = readFiles.prefix(readNum)
                var allCommonHistory: [CommonHistory] = []
                latestFiles.forEach({ (keyStr: String) in
                    do {
                        let data = try Data(contentsOf: AppConst.commonHistoryUrl(date: keyStr))
                        let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
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
            let saveData: [CommonHistory]? = { () -> [CommonHistory]? in
                do {
                    let data = try Data(contentsOf: commonHistoryUrl)
                    let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
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
}

class CommonHistory: NSObject, NSCoding {
    var _id: String = NSUUID().uuidString
    var url: String = ""
    var title: String = ""
    var date: Date = Date()
    
    override init() {
        super.init()
    }
    
    init(_id: String = NSUUID().uuidString, url: String, title: String, date: Date) {
        self._id = _id
        self.url = url
        self.title = title
        self.date = date
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let _id = decoder.decodeObject(forKey: "_id") as! String
        let url = decoder.decodeObject(forKey: "url") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let date = decoder.decodeObject(forKey: "date") as! Date
        self.init(_id: _id, url: url, title: title, date: date)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
    }
}
