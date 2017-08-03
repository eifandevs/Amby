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
    func baseViewModelDidAutoScroll()
    func baseViewModelDidAutoInput()
}

class BaseViewModel {
    
    // リクエストURL(jsのURL)
    var requestUrl: String {
        get {
            return eachHistory[safe: locationIndex] != nil ? eachHistory[locationIndex].url : ""
        }
    }
    
    var headerFieldText: String = "" {
        didSet {
            center.post(name: .headerViewModelWillChangeField, object: headerFieldText)
        }
    }
    
    var reloadUrl: String {
        get {
            return headerFieldText
        }
    }
    
    var delegate: BaseViewModelDelegate?
    
    // 最新のリクエストURL(wv.url)。エラーが発生した時用
    var latestRequestUrl: String = ""
    
    // webviewの数
    var webViewCount: Int {
        get {
            return eachHistory.count
        }
    }
    
    // 現在表示しているwebviewのインデックス
    var locationIndex: Int  = UserDefaults.standard.integer(forKey: AppConst.locationIndexKey) {
        didSet {
            log.debug("location index changed. \(oldValue) -> \(locationIndex)")
        }
    }
    
    // 全てのwebViewの履歴
    private var commonHistory: [CommonHistoryItem] = []
    
    // webViewそれぞれの履歴とカレントページインデックス
    private var eachHistory: [HistoryItem] = []
    
    // 通知センター
    let center = NotificationCenter.default
    
    var isPrivateMode: Bool? {
        get {
            return eachHistory.count > locationIndex ? eachHistory[locationIndex].isPrivate == "true" : nil
        }
    }
    
    // 自動スクロールのタイムインターバル
    var autoScrollInterval: CGFloat {
        get {
            return CGFloat(UserDefaults.standard.float(forKey: AppConst.autoScrollIntervalKey))
        }
    }
    
    let autoScrollSpeed: CGFloat = 0.6
    
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
            let url = notification.object != nil ? (notification.object as! [String: String])["url"] : nil
            if url == nil {
                self!.eachHistory.append(HistoryItem())
            } else {
                self!.eachHistory.append(HistoryItem(url: url!))
            }
            self!.locationIndex = self!.eachHistory.count - 1
            self!.center.post(name: .footerViewModelWillAddWebView, object: self!.eachHistory.last!)
            self!.delegate?.baseViewModelDidAddWebView()
        }
        
        // private webviewの追加作成
        center.addObserver(forName: .baseViewModelWillAddPrivateWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillAddPrivateWebView")
            let url = notification.object != nil ? (notification.object as! [String: String])["url"] : nil
            if url == nil {
                self!.eachHistory.append(HistoryItem(isPrivate: "true"))
            } else {
                self!.eachHistory.append(HistoryItem(url: url!, isPrivate: "true"))
            }
            self!.locationIndex = self!.eachHistory.count - 1
            self!.center.post(name: .footerViewModelWillAddWebView, object: self!.eachHistory.last!)
            self!.delegate?.baseViewModelDidAddWebView()
        }
        
        // 閲覧履歴の削除
        center.addObserver(forName: .baseViewModelWillDeleteHistory, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillDeleteHistory")
            self!.commonHistory = []
        }
        
        // 初期化
        center.addObserver(forName: .baseViewModelWillInitialize, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillInitialize")
            self!.commonHistory = []
            self!.eachHistory = []
        }
        
        // webviewのコピー
        center.addObserver(forName: .baseViewModelWillCopyWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillCopyWebView")
            self!.eachHistory.append(HistoryItem(url: self!.eachHistory[self!.locationIndex].url, title: self!.eachHistory[self!.locationIndex].title))
            self!.locationIndex = self!.eachHistory.count - 1
            self!.center.post(name: .footerViewModelWillAddWebView, object: ["context": self!.currentContext])
            self!.delegate?.baseViewModelDidAddWebView()
        }
        
        // webviewのリロード
        center.addObserver(forName: .baseViewModelWillReloadWebView, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillReloadWebView")
            self!.delegate?.baseViewModelDidReloadWebView()
        }
        
        // webviewの自動入力
        center.addObserver(forName: .baseViewModelWillAutoInput, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillAutoInput")
            self!.delegate?.baseViewModelDidAutoInput()
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
        // フロントwebviewの変更
        center.addObserver(forName: .baseViewModelWillStoreHistory, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillStoreHistory")
            self!.storeHistory()
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
        // webviewお気に入り更新
        center.addObserver(forName: .baseViewModelWillChangeFavorite, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillChangeFavorite")
            // 現在表示しているURLがお気に入りかどうか調べる
            let currentUrl = self!.eachHistory[self!.locationIndex].url
            if (!currentUrl.isEmpty) {
                let savedFavoriteUrls = CommonDao.s.selectAllFavorite().map({ (f) -> String in
                    return f.url.domainAndPath
                })
                self!.center.post(name: .headerViewModelWillChangeFavorite, object: savedFavoriteUrls.contains(currentUrl.domainAndPath))
            }
        }
        
        // webviewお気に入り登録
        center.addObserver(forName: .baseViewModelWillRegisterAsFavorite, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillRegisterAsFavorite")
            if (!self!.eachHistory[self!.locationIndex].url.isEmpty && !self!.eachHistory[self!.locationIndex].title.isEmpty) {
                let fd = Favorite()
                fd.title = self!.eachHistory[self!.locationIndex].title
                fd.url = self!.eachHistory[self!.locationIndex].url
                
                if let favoriteData = CommonDao.s.selectFavorite(url: fd.url) {
                    // すでに登録済みの場合は、お気に入りから削除する
                    CommonDao.s.deleteWithRLMObjects(data: [favoriteData])
                    self!.center.post(name: .headerViewModelWillChangeFavorite, object: false)
                } else {
                    CommonDao.s.insertWithRLMObjects(data: [fd])
                    // ヘッダーのお気に入りアイコン更新。headerViewModelに通知する
                    self!.center.post(name: .headerViewModelWillChangeFavorite, object: true)
                    Util.presentWarning(title: "登録完了", message: "お気に入りに登録しました。")
                }
            } else {
                Util.presentWarning(title: "登録エラー", message: "登録情報を取得できませんでした。")
            }
        }
        // webviewフォーム情報登録
        center.addObserver(forName: .baseViewModelWillRegisterAsForm, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillRegisterAsForm")
            self!.delegate?.baseViewModelDidRegisterAsForm()
        }
        // webview自動スクロール
        center.addObserver(forName: .baseViewModelWillAutoScroll, object: nil, queue: nil) { [weak self] (notification) in
            log.debug("[BaseView Event]: baseViewModelWillAutoScroll")
            self!.delegate?.baseViewModelDidAutoScroll()
        }
        // eachHistory読み込み
        do {
            let data = try Data(contentsOf: AppConst.eachHistoryUrl)
            eachHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [HistoryItem]
            log.debug("each history read. url: \n\(requestUrl)")
        } catch let error as NSError {
            eachHistory.append(HistoryItem())
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
    
    func notifyBeginEditing() {
        center.post(name: .headerViewModelWillBeginEditing, object: false)
    }
    
    func reloadHeaderText() {
        headerFieldText = requestUrl
    }
    
    func saveHistory(wv: EGWebView) {
        if !isPrivateMode! {
            if let requestUrl = wv.requestUrl, let requestTitle = wv.requestTitle, !requestTitle.isEmpty {
                //　アプリ起動後の前回ページロード時は、履歴に保存しない
                if requestUrl != self.requestUrl {
                    // ヘッダーのお気に入りアイコン更新。headerViewModelに通知する
                    center.post(name: .headerViewModelWillChangeFavorite, object: CommonDao.s.selectFavorite(url: requestUrl) != nil)
                    // Common History
                    let common = CommonHistoryItem(url: requestUrl, title: requestTitle, date: Date())
                    // 配列の先頭に追加する
                    commonHistory.insert(common, at: 0)
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
        }
    }
    
    func storeHistory() {
        UserDefaults.standard.set(locationIndex, forKey: AppConst.locationIndexKey)
        CommonDao.s.storeCommonHistory(commonHistory: commonHistory)
        if commonHistory.count > 0 {
            CommonDao.s.storeEachHistory(eachHistory: eachHistory)
        }
        commonHistory = []
    }
}
