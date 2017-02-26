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

    // リクエストURL。これを変更すると、BaseViewがそのURLでロードする
    var requestUrl = Observable("http://about:blank")

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
    
    private var defaultUrl: String {
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
        let saveUrl = (((wv.hasValidUrl || wv.errorUrl == nil) ? wv.url : wv.errorUrl)?.absoluteString.removingPercentEncoding)!
        // Common History
        let common = CommonHistoryItem(url: saveUrl, title: wv.title!)
        commonHistory.append(common)
        log.debug("save history. url: \(common.url)")
        
        // Each History
        let each = EachHistoryItem(url: saveUrl, title: common.title)
        eachHistory[locationIndex] = each        
    }
    
    func storeHistory() {
        storeCommonHistory()
        storeEachHistory()
        commonHistory = []
    }
    
    private func storeCommonHistory() {
        if commonHistory.count > 0 {
            // 現在保存しているものに追加する
//            let saveData = { () -> [CommonHistoryItem] in
//                do {
//                    let data = try Data(contentsOf: AppDataManager.shared.commonHistoryPath)
//                    return NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistoryItem] + self.commonHistory
//                } catch let error as NSError {
//                    log.error("failed to read: \(error)")
//                    return self.commonHistory
//                }
//            }
//            
//            log.debug("これから保存するCommonData: \(saveData)")
            let saveData: [CommonHistoryItem] = { () -> [CommonHistoryItem] in
                do {
                    let data = try Data(contentsOf: AppDataManager.shared.commonHistoryPath)
                    let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistoryItem]
                    let saveData: [CommonHistoryItem] = old + commonHistory
                    return saveData
                } catch let error as NSError {
                    log.error("failed to read: \(error)")
                    return commonHistory
                }
            }()
            
            log.debug("保存するCommonData: \(saveData)")
            let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
            do {
                try commonHistoryData.write(to: AppDataManager.shared.commonHistoryPath)
                log.debug("store common history")
            } catch let error as NSError {
                log.error("failed to write: \(error)")
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
