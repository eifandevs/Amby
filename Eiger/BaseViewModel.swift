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

    private let historyModel = HistoryModel()

    // 現在表示しているwebviewのインデックス
    private var locationIndex = 0
    
    // 全てのwebViewの履歴
    private var commonHistory: [History] = []
    
    // webViewそれぞれの履歴とカレントページインデックス
    var eachHistory: [EachHistoryItem] = [EachHistoryItem(history: [], index: -1)]
    
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
        // TODO: コメントを外す
//        do {
//            let data = try Data(contentsOf: AppDataManager.shared.historyPath)
//            eachHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EachHistoryItem]
//            log.debug("history info read: \n\(eachHistory)")
//        } catch let error as NSError {
//            log.error("failed to read: \(error)")
//        }
    }
    
    func incrementLocation(wv: EGWebView) {
        if currentHistory.history.count > currentHistory.index + 1 {
            wv.isHistoryRequest = true
            requestUrl.value = currentHistory.history[currentHistory.index + 1]
            eachHistory[locationIndex].index += 1
            log.debug("進むを検知。index: \(eachHistory[locationIndex].index - 1) -> \(eachHistory[locationIndex].index)")
        } else {
            log.warning("can not go forward webview")
        }
    }

    func decrementLocation(wv: EGWebView) {
        if 0 <= currentHistory.index - 1 {
            wv.isHistoryRequest = true
            requestUrl.value = currentHistory.history[currentHistory.index - 1]
            eachHistory[locationIndex].index -= 1
            log.debug("戻るを検知。index: \(eachHistory[locationIndex].index + 1) -> \(eachHistory[locationIndex].index)")
            
        } else {
            log.warning("can not back webview")
        }
    }

    func saveCommonHistory(wv: EGWebView) {
        if wv.isLocalRequest() == false {
            let h = History()
            h.title = wv.title!
            h.url = (wv.url?.absoluteString.removingPercentEncoding)!
            h.date = Date()
            
            commonHistory.append(h)
            log.debug("save common history. url: \(h.url)")
        }
        
        // each historyを更新する
        if wv.isHistoryRequest == false {
            // ページを戻る(進む)アクションの場合は、eachHistoryには追加しない
            saveEachHistory(wv: wv)
        }
        wv.previousUrl = wv.url
        wv.isHistoryRequest = false // 読み込みが終わったら、履歴リクエストフラグを落としておく
    }
    
    func storeCommonHistory() {
        if commonHistory.count > 0 {
            let savingTerm = Date(timeIntervalSinceNow: -1 * Double(historySavableTerm) * 24 * 60 * 60)
            let deleteHistory = historyModel.select().filter({ $0.date < savingTerm })
            if deleteHistory.count > 0 {
                historyModel.deleteWithRLMObjects(data: deleteHistory)
            }
            historyModel.insertWithRLMObjects(data: commonHistory)
            log.debug("store common history. all history: \(historyModel.select())")
            commonHistory = []
        }
    }
    
    func storeEachHistory() {
        // hisotryInfo書き込み
        let historyInfoData =  NSKeyedArchiver.archivedData(withRootObject: eachHistory)
        do {
            try historyInfoData.write(to: AppDataManager.shared.historyPath)
            log.debug("store each history")
        } catch let error as NSError {
            log.error("failed to write: \(error)")
        }
    }
    
    func refresh(wv: EGWebView) {
        wv.isHistoryRequest = true // 読み込みが終わったら、履歴リクエストフラグを落としておく
        requestUrl.value = currentHistory.history[currentHistory.index]
    }
    
    private func saveEachHistory(wv: EGWebView) {
        let originalUrl = (wv.originalUrl?.absoluteString.removingPercentEncoding)!
        let requestUrl = (wv.url?.absoluteString.removingPercentEncoding)!
        if currentHistory.index + 1 < currentHistory.history.count {
            // ページを戻るで過去ページに戻り、別のリンクをタップした場合は、新しいルートで履歴をとる
            eachHistory[locationIndex].history[(currentHistory.index + 1)...(currentHistory.history.count - 1)] = []
        }
        let addUrl = (requestUrl.hasPrefix("file://") == true) ? originalUrl : requestUrl
        log.debug("save each history. url: \(addUrl)")
        eachHistory[locationIndex].add(urlStr: addUrl)
    }
}
