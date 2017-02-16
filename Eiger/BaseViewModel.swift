//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class BaseViewModel {
    
    private let historyModel = HistoryModel()

    // 現在表示しているwebviewのインデックス
    private var locationIndex = 0
    
    // 全てのwebViewの履歴
    private var commonHistory: [History] = []
    
    // webViewそれぞれの履歴とカレントページインデックス
    var eachHistory: [EachHistoryItem] = [EachHistoryItem()]
    
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
    
    private var currentHistory: EachHistoryItem {
        get {
            return eachHistory[locationIndex]
        }
    }
    
    init() {
        // historyInfo読み込み
        do {
            let data = try Data(contentsOf: AppDataManager.shared.historyPath)
            eachHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EachHistoryItem]
            log.debug("history info read: \n\(eachHistory)")
        } catch let error as NSError {
            log.error("failed to read: \(error)")
        }
    }
    
    func requestNextUrl() -> String? {
        return (currentHistory.history.count >= currentHistory.index + 1) ? currentHistory.history[currentHistory.index + 1] : nil
    }
    
    func requestPrevUrl() -> String? {
        return (0 <= currentHistory.index - 1) ? currentHistory.history[currentHistory.index - 1] : nil
    }
    
    func saveCommonHistory(webView: EGWebView) {
        if (hasValidUrl(webView: webView)) {
            let h = History()
            h.title = webView.title!
            h.url = (webView.url?.absoluteString.removingPercentEncoding)!
            h.date = Date()
            
            commonHistory.append(h)
            log.debug("save history. url: \(h.url)")
            
            // each historyも更新する
            saveEachHistory(urlStr: h.url)
        }
        webView.previousUrl = webView.url
    }
    
    func storeCommonHistory() {
        if commonHistory.count > 0 {
            let savingTerm = Date(timeIntervalSinceNow: -1 * Double(historySavableTerm) * 24 * 60 * 60)
            let deleteHistory = historyModel.select().filter({ $0.date < savingTerm })
            if deleteHistory.count > 0 {
                historyModel.deleteWithRLMObjects(data: deleteHistory)
            }
            historyModel.insertWithRLMObjects(data: commonHistory)
            log.debug("store history. all history: \(historyModel.select())")
            commonHistory = []
        }
    }
    
    func storeEachHistory() {
        // hisotryInfo書き込み
        let historyInfoData =  NSKeyedArchiver.archivedData(withRootObject: eachHistory)
        do {
            try historyInfoData.write(to: AppDataManager.shared.historyPath)
        } catch let error as NSError {
            log.error("failed to write: \(error)")
        }
    }
    
    private func saveEachHistory(urlStr: String) {
        eachHistory[locationIndex].add(urlStr: urlStr)
    }
    
    private func hasValidUrl(webView: EGWebView) -> Bool {
        return ((webView.title != nil) &&
                (webView.url != nil) &&
                (webView.previousUrl != nil) &&
                (webView.previousUrl?.absoluteString != webView.url?.absoluteString))
    }
}
