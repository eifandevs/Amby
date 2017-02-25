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
    var requestUrl = Observable(UserDefaults.standard.string(forKey: AppDataManager.shared.defaultUrlKey)!)

    // 現在表示しているwebviewのインデックス
    private var locationIndex = 0
    
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
    
    private var historySavableTerm: Int {
        get {
            return UserDefaults.standard.integer(forKey: AppDataManager.shared.historySavableTermKey)
        }
    }
    
    init() {
        // historyInfo読み込み
        // TODO: コメントを外す
//        do {
//            let data = try Data(contentsOf: AppDataManager.shared.historyPath)
//            eachHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EachHistoryItem]
//            log.debug("history info read: \n\(eachHistory)")
//        } catch let error as NSError {
//            log.error("failed to read: \(error)")
//        }
    }

    func saveHistory(wv: EGWebView) {
        // Common History
        let common = CommonHistoryItem(url: (wv.url?.absoluteString.removingPercentEncoding)!, title: wv.title!, date: Date())
        commonHistory.append(common)
        log.debug("save history. url: \(common.url)")
        
        // Each History
        let each = EachHistoryItem(url: common.url, title: common.title)
        eachHistory[locationIndex] = each
        
        wv.previousUrl = wv.url
    }
    
    func storeCommonHistory() {
        if commonHistory.count > 0 {
            let historyInfoData = NSKeyedArchiver.archivedData(withRootObject: commonHistory)
            do {
                try historyInfoData.write(to: AppDataManager.shared.commonHistoryPath)
                log.debug("store common history")
            } catch let error as NSError {
                log.error("failed to write: \(error)")
            }
        }
    }
    
    func storeEachHistory() {
        // hisotryInfo書き込み
        let historyInfoData = NSKeyedArchiver.archivedData(withRootObject: eachHistory)
        do {
            try historyInfoData.write(to: AppDataManager.shared.eachHistoryPath)
            log.debug("store each history")
        } catch let error as NSError {
            log.error("failed to write: \(error)")
        }
    }
}
