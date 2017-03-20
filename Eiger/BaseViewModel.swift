//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Bond

class BaseViewModel {
    
    // リクエストURL(jsのURL)
    var requestUrl = Observable("http://about:blank")
    
    // 最新のリクエストURL(wv.url)。エラーが発生した時用
    var latestRequestUrl: String = ""

    // 現在表示しているwebviewのインデックス
    private var locationIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: AppDataManager.shared.locationIndexKey)
        }
        set(index) {
            UserDefaults.standard.set(index, forKey: AppDataManager.shared.locationIndexKey)
        }
    }
    
    // 全てのwebViewの履歴
    private var commonHistory: [CommonHistoryItem] = []
    
    // webViewそれぞれの履歴とカレントページインデックス
    private var eachHistory: [EachHistoryItem] = [EachHistoryItem()]
    
    var defaultUrl: String {
        get {
            return UserDefaults.standard.string(forKey: AppDataManager.shared.defaultUrlKey)!
        }
        set(url) {
            UserDefaults.standard.set(url, forKey: AppDataManager.shared.defaultUrlKey)
        }
    }
    
    init() {
        // eachHistory読み込み
        do {
            let data = try Data(contentsOf: AppDataManager.shared.eachHistoryPath)
            eachHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EachHistoryItem]
            requestUrl.value = eachHistory[locationIndex].url
            log.debug("each history read. url: \n\(eachHistory[locationIndex].url)")
        } catch let error as NSError {
            requestUrl.value = defaultUrl
            log.error("failed to read: \(error)")
        }
    }
    
    func saveHistory(wv: EGWebView) {
        // Common History
        let common = CommonHistoryItem(url: wv.requestUrl, title: wv.requestTitle, date: Date())
        commonHistory.append(common)
        log.debug("save history. url: \(common.url)")
        
        // Each History
        let each = EachHistoryItem(url: common.url, title: common.title)
        eachHistory[locationIndex] = each
    }
    
    func storeHistory() {
        storeCommonHistory()
        storeEachHistory()
        commonHistory = []
    }
    
    private func storeCommonHistory() {
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
                let commonHistoryPath = AppDataManager.shared.commonHistoryPath(date: key)
                
                let saveData: [CommonHistoryItem] = { () -> [CommonHistoryItem] in
                    do {
                        let data = try Data(contentsOf: commonHistoryPath)
                        let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistoryItem]
                        let saveData: [CommonHistoryItem] = old + value
                        return saveData
                    } catch let error as NSError {
                        log.error("failed to read: \(error)")
                        return value
                    }
                }()
                
                //                log.debug("*********** 保存するCommonHistory **************")
                //                for data in saveData {
                //                    log.debug("url: \(data.url)")
                //                    log.debug("date: \(data.date)")
                //                }
                //                log.debug("***********************************************")
                
                let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                do {
                    try commonHistoryData.write(to: commonHistoryPath)
                    log.debug("store common history")
                } catch let error as NSError {
                    log.error("failed to write: \(error)")
                }
            }
        }
    }
    
    private func storeEachHistory() {
        if commonHistory.count > 0 {
            let eachHistoryData = NSKeyedArchiver.archivedData(withRootObject: eachHistory)
            do {
                try eachHistoryData.write(to: AppDataManager.shared.eachHistoryPath)
                log.debug("store each history")
            } catch let error as NSError {
                log.error("failed to write: \(error)")
            }
        }
    }
}
