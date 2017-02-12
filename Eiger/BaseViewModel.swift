//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class BaseViewModel {
    private var history: [History] = []
    private let historyModel = HistoryModel()
    
    var defaultUrl: String {
        get {
            return UserDefaults.standard.string(forKey: AppDataManager.shared.defaultUrlKey)!
        }
        set(url) {
            UserDefaults.standard.set(url, forKey: AppDataManager.shared.defaultUrlKey)
        }
    }
    var historySavableTerm: Int {
        get {
            return UserDefaults.standard.integer(forKey: AppDataManager.shared.historySavableTermKey)
        }
    }
    
    func saveHistory(webView: EGWebView) {
        if (hasValidUrl(webView: webView)) {
            let h = History()
            h.title = webView.title!
            h.url = (webView.url?.absoluteString.removingPercentEncoding)!
            h.date = Date()
            
            history.append(h)
            log.debug("save history. url: \(h.url)")
        }
        webView.previousUrl = webView.url
    }
    
    func storeHistory() {
        if history.count > 0 {
            let savingTerm = Date(timeIntervalSinceNow: -1 * Double(historySavableTerm) * 24 * 60 * 60)
            let deleteHistory = historyModel.select().filter({ $0.date < savingTerm })
            if deleteHistory.count > 0 {
                historyModel.deleteWithRLMObjects(data: deleteHistory)
            }
            historyModel.insertWithRLMObjects(data: history)
            log.debug("store history. all history: \(historyModel.select())")
            history = []
        }
    }
    
    private func hasValidUrl(webView: EGWebView) -> Bool {
        return ((webView.title != nil) &&
                (webView.url != nil) &&
                (webView.previousUrl != nil) &&
                (webView.previousUrl?.absoluteString != webView.url?.absoluteString))
    }
}
