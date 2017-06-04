//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Bond
import WebKit

protocol BaseViewModelDelegate {
    func baseViewModelDidAddWebView()
    func baseViewModelDidReloadWebView()
    func baseViewModelDidChangeWebView()
    func baseViewModelDidRemoveWebView(index: Int, isFrontDelete: Bool)
    func baseViewModelDidHistoryBackWebView()
    func baseViewModelDidHistoryForwardWebView()
    func baseViewModelDidSearchWebView(text: String)
    func baseViewModelDidRegisterAsForm()
}

class BaseViewModel {
    
    // リクエストURL(jsのURL)
    var requestUrl: String {
        get {
            return (!eachHistory[locationIndex].url.isEmpty) ? eachHistory[locationIndex].url : defaultUrl
        }
    }
    
    var headerFieldText: String = "" {
        didSet {
            center.post(name: .headerViewModelWillChangeField, object: headerFieldText)
        }
    }
    
    var reloadUrl: String {
        get {
            return headerFieldText.isEmpty ? defaultUrl : headerFieldText
        }
    }
    
    var delegate: BaseViewModelDelegate?
    
    // クッキーの共有
    var processPool = WKProcessPool()
    
    // 最新のリクエストURL(wv.url)。エラーが発生した時用
    var latestRequestUrl: String = ""
    
    // webviewの数
    var webViewCount: Int {
        get {
            return eachHistory.count
        }
    }
    
    // 現在表示しているwebviewのインデックス
    var locationIndex: Int  = UserDefaults.standard.integer(forKey: AppDataManager.shared.locationIndexKey) {
        didSet {
            log.debug("location index changed. \(oldValue) -> \(locationIndex)")
        }
    }
    
    // 全てのwebViewの履歴
    private var commonHistory: [CommonHistoryItem] = []
    
    // webViewそれぞれの履歴とカレントページインデックス
    private var eachHistory: [EachHistoryItem] = []
    
    // 通知センター
    let center = NotificationCenter.default
    
    var defaultUrl: String {
        get {
            return UserDefaults.standard.string(forKey: AppDataManager.shared.defaultUrlKey)!
        }
        set(url) {
            UserDefaults.standard.set(url, forKey: AppDataManager.shared.defaultUrlKey)
        }
    }
    
    var currentContext: String? {
        get {
            return eachHistory.count > locationIndex ? eachHistory[locationIndex].context : nil
        }
    }
    
    init() {
        // バックグラウンドに入るときに履歴を保存する
        center.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            self!.storeHistory()
        }
        // webviewの追加作成
        center.addObserver(forName: .baseViewModelWillAddWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillAddWebView")
            self!.eachHistory.append(EachHistoryItem())
            self!.locationIndex = self!.eachHistory.count - 1
            self!.center.post(name: .footerViewModelWillAddWebView, object: ["context": self!.currentContext])
            self!.delegate?.baseViewModelDidAddWebView()
        }
        // webviewのリロード
        center.addObserver(forName: .baseViewModelWillReloadWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillReloadWebView")
            self!.delegate?.baseViewModelDidReloadWebView()
        }
        // フロントwebviewの変更
        center.addObserver(forName: .baseViewModelWillChangeWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillChangeWebView")
            self!.center.post(name: .footerViewModelWillChangeWebView, object: notification.object)
            let index = notification.object as! Int
            if self!.locationIndex != index {
                self!.locationIndex = index
                self!.delegate?.baseViewModelDidChangeWebView()
            } else {
                log.warning("selected current webView")
            }
        }
        // webviewの削除
        center.addObserver(forName: .baseViewModelWillRemoveWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillRemoveWebView")
            let index = ((notification.object as? Int) != nil) ? notification.object as! Int : self!.locationIndex
            let isFrontDelete = self!.locationIndex == index
            self!.center.post(name: .footerViewModelWillRemoveWebView, object: index)
            if ((index != 0 && self!.locationIndex == index && index == self!.eachHistory.count - 1) || (index < self!.locationIndex)) {
                // indexの調整
                self!.locationIndex = self!.locationIndex - 1
            }
            self!.eachHistory.remove(at: index)
            self!.delegate?.baseViewModelDidRemoveWebView(index: index, isFrontDelete: isFrontDelete)
        }
        // webview検索
        center.addObserver(forName: .baseViewModelWillSearchWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillSearchWebView")
            let text = notification.object as! String
            self!.delegate?.baseViewModelDidSearchWebView(text: text)
        }
        // webviewヒストリバック
        center.addObserver(forName: .baseViewModelWillHistoryBackWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillHistoryBackWebView")
            self!.delegate?.baseViewModelDidHistoryBackWebView()
        }
        // webviewヒストリフォワード
        center.addObserver(forName: .baseViewModelWillHistoryForwardWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillHistoryForwardWebView")
            self!.delegate?.baseViewModelDidHistoryForwardWebView()
        }
        // webviewお気に入り登録
        center.addObserver(forName: .baseViewModelWillRegisterAsFavorite, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillRegisterAsFavorite")
            if (!self!.eachHistory[self!.locationIndex].url.isEmpty && !self!.eachHistory[self!.locationIndex].title.isEmpty) {
                let fd = Favorite()
                fd.title = self!.eachHistory[self!.locationIndex].title
                fd.url = self!.eachHistory[self!.locationIndex].url
                StoreManager.shared.insertWithRLMObjects(data: [fd])
                
                log.debug(StoreManager.shared.selectAllFavoriteInfo())
                Util.shared.presentWarning(title: "登録完了", message: "お気に入りに登録しました。")
            } else {
                Util.shared.presentWarning(title: "登録エラー", message: "登録情報を取得できませんでした。")
            }
        }
        // webviewフォーム情報登録
        center.addObserver(forName: .baseViewModelWillRegisterAsForm, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillRegisterAsForm")
            self!.delegate?.baseViewModelDidRegisterAsForm()
        }
        
        // eachHistory読み込み
        do {
            let data = try Data(contentsOf: AppDataManager.shared.eachHistoryPath)
            eachHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EachHistoryItem]
            log.debug("each history read. url: \n\(requestUrl)")
        } catch let error as NSError {
            eachHistory.append(EachHistoryItem())
            log.error("failed to read each history: \(error)")
        }
        center.post(name: .footerViewModelWillLoad, object: eachHistory)
    }
    
// MARK: Public Method
    
    func notifyStartLoadingWebView(object: [String: Any]?) {
        center.post(name: .footerViewModelWillStartLoading, object: object)
    }
    
    func notifyEndLoadingWebView(object: [String: Any]?) {
        center.post(name: .footerViewModelWillEndLoading, object: object)
    }
    
    func notifyChangeProgress(object: CGFloat) {
        center.post(name: .headerViewModelWillChangeProgress, object: object)
    }
    
    func notifyAddWebView() {
        center.post(name: .baseViewModelWillAddWebView, object: nil)
    }
    
    func saveHistory(wv: EGWebView) {
        if let requestUrl = wv.requestUrl, let requestTitle = wv.requestTitle {
            // Common History
            let common = CommonHistoryItem(url: requestUrl, title: requestTitle, date: Date())
            commonHistory.append(common)
            log.debug("save history. url: \(common.url)")
            
            // Each History
            for history in eachHistory {
                if history.context == wv.context {
                    history.url = common.url
                    history.title = common.title
                    break
                }
            }
        }
    }
    
    func storeHistory() {
        UserDefaults.standard.set(locationIndex, forKey: AppDataManager.shared.locationIndexKey)
        storeCommonHistory()
        storeEachHistory()
        commonHistory = []
    }
    
// MARK: Private Method
    
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
