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

protocol BaseViewModelDelegate: class {
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
    
    weak var delegate: BaseViewModelDelegate?
    
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
            // locationIndexに動きがあったら、インデックスとeachHistoryを保存する
            UserDefaults.standard.set(locationIndex, forKey: AppConst.locationIndexKey)
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
            return eachHistory.count > locationIndex ? eachHistory[locationIndex].isPrivate == "true" : false
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
            guard let `self` = self else { return }
            self.storeHistory()
        }
        // webviewの追加作成
        center.addObserver(forName: .baseViewModelWillAddWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillAddWebView")
            let url = notification.object != nil ? (notification.object as! [String: String])["url"] : nil
            self.addWebView(url: url)
        }
        
        // private webviewの追加作成
        center.addObserver(forName: .baseViewModelWillAddPrivateWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillAddPrivateWebView")
            let url = notification.object != nil ? (notification.object as! [String: String])["url"] : nil
            self.addWebView(url: url, isPrivate: "true")
        }
        
        // 閲覧履歴の削除
        center.addObserver(forName: .baseViewModelWillDeleteHistory, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillDeleteHistory")
            self.commonHistory = []
        }
        
        // 初期化
        center.addObserver(forName: .baseViewModelWillInitialize, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillInitialize")
            self.commonHistory = []
            self.eachHistory = []
        }
        
        // webviewのコピー
        center.addObserver(forName: .baseViewModelWillCopyWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillCopyWebView")
            self.eachHistory.append(HistoryItem(url: self.eachHistory[self.locationIndex].url, title: self.eachHistory[self.locationIndex].title))
            self.locationIndex = self.eachHistory.count - 1
            self.center.post(name: .footerViewModelWillAddWebView, object: self.eachHistory[self.locationIndex])
            self.delegate?.baseViewModelDidAddWebView()
        }
        
        // webviewのリロード
        center.addObserver(forName: .baseViewModelWillReloadWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillReloadWebView")
            self.delegate?.baseViewModelDidReloadWebView()
        }
        
        // webviewの自動入力
        center.addObserver(forName: .baseViewModelWillAutoInput, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillAutoInput")
            self.delegate?.baseViewModelDidAutoInput()
        }
        
        // フロントwebviewの変更
        center.addObserver(forName: .baseViewModelWillChangeWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillChangeWebView")
            self.changeWebView(index: notification.object as! Int)
        }
        // フロントwebviewの変更
        center.addObserver(forName: .baseViewModelWillStoreHistory, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillStoreHistory")
            self.storeHistory()
        }
        // webviewの削除
        center.addObserver(forName: .baseViewModelWillRemoveWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillRemoveWebView")
            let index = ((notification.object as? Int) != nil) ? notification.object as! Int : self.locationIndex
            let isFrontDelete = self.locationIndex == index
            self.center.post(name: .footerViewModelWillRemoveWebView, object: index)
            if ((index != 0 && self.locationIndex == index && index == self.eachHistory.count - 1) || (index < self.locationIndex)) {
                // indexの調整
                self.locationIndex = self.locationIndex - 1
            }
            self.eachHistory.remove(at: index)
            self.reloadFavorite()
            self.delegate?.baseViewModelDidRemoveWebView(index: index, isFrontDelete: isFrontDelete)
        }
        // webview検索
        center.addObserver(forName: .baseViewModelWillSearchWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillSearchWebView")
            let text = notification.object as! String
            self.delegate?.baseViewModelDidSearchWebView(text: text)
        }
        
        // URLコピー
        center.addObserver(forName: .baseViewModelWillCopyUrl, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillCopyUrl")
            UIPasteboard.general.string = self.requestUrl
            Util.presentWarning(title: "", message: "URLをコピーしました。")
        }
        // webviewヒストリバック
        center.addObserver(forName: .baseViewModelWillHistoryBackWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillHistoryBackWebView")
            self.delegate?.baseViewModelDidHistoryBackWebView()
        }
        // webviewヒストリフォワード
        center.addObserver(forName: .baseViewModelWillHistoryForwardWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillHistoryForwardWebView")
            self.delegate?.baseViewModelDidHistoryForwardWebView()
        }
        // webviewお気に入り更新
        center.addObserver(forName: .baseViewModelWillChangeFavorite, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillChangeFavorite")
            self.reloadFavorite()
        }
        
        // webviewお気に入り登録
        center.addObserver(forName: .baseViewModelWillRegisterAsFavorite, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillRegisterAsFavorite")
            if (!self.eachHistory[self.locationIndex].url.isEmpty && !self.eachHistory[self.locationIndex].title.isEmpty) {
                let fd = Favorite()
                fd.title = self.eachHistory[self.locationIndex].title
                fd.url = self.eachHistory[self.locationIndex].url
                
                if let favoriteData = CommonDao.s.selectFavorite(url: fd.url) {
                    // すでに登録済みの場合は、お気に入りから削除する
                    CommonDao.s.deleteWithRLMObjects(data: [favoriteData])
                    self.center.post(name: .headerViewModelWillChangeFavorite, object: false)
                } else {
                    CommonDao.s.insertWithRLMObjects(data: [fd])
                    // ヘッダーのお気に入りアイコン更新。headerViewModelに通知する
                    self.center.post(name: .headerViewModelWillChangeFavorite, object: true)
                    Util.presentWarning(title: "登録完了", message: "お気に入りに登録しました。")
                }
            } else {
                Util.presentWarning(title: "登録エラー", message: "登録情報を取得できませんでした。")
            }
        }
        // webviewフォーム情報登録
        center.addObserver(forName: .baseViewModelWillRegisterAsForm, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillRegisterAsForm")
            self.delegate?.baseViewModelDidRegisterAsForm()
        }
        // webview自動スクロール
        center.addObserver(forName: .baseViewModelWillAutoScroll, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillAutoScroll")
            self.delegate?.baseViewModelDidAutoScroll()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func addWebView(url: String? = nil, isPrivate: String = "false") {
        if let url = url {
            self.eachHistory.append(HistoryItem(url: url, isPrivate: isPrivate))
        } else {
            self.eachHistory.append(HistoryItem(isPrivate: isPrivate))
        }
        self.locationIndex = self.eachHistory.count - 1
        self.reloadFavorite()
        self.center.post(name: .footerViewModelWillAddWebView, object: self.eachHistory.last!)
        self.delegate?.baseViewModelDidAddWebView()
    }
    
    func notifyBeginEditing() {
        center.post(name: .headerViewModelWillBeginEditing, object: false)
    }
    
    func reloadHeaderText() {
        headerFieldText = requestUrl
    }
    
    func changePreviousWebView() {
        changeWebView(index: locationIndex - 1)
    }
    
    func changeNextWebView() {
        changeWebView(index: locationIndex + 1)
    }
    
    func saveHistory(wv: EGWebView) {
        if !isPrivateMode! {
            if let requestUrl = wv.requestUrl, let requestTitle = wv.requestTitle, !requestTitle.isEmpty {
                // ヘッダーのお気に入りアイコン更新。headerViewModelに通知する
                center.post(name: .headerViewModelWillChangeFavorite, object: CommonDao.s.selectFavorite(url: requestUrl) != nil)
                //　アプリ起動後の前回ページロード時は、履歴に保存しない
                if requestUrl != self.requestUrl {
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
        CommonDao.s.storeCommonHistory(commonHistory: commonHistory)
        CommonDao.s.storeEachHistory(eachHistory: eachHistory)
        commonHistory = []
    }
    
    func storeEachHistory() {
        CommonDao.s.storeEachHistory(eachHistory: eachHistory)
    }
    
// MARK: Private Method
    private func changeWebView(index: Int) {
        if index < 0 {
            log.error("change webview error")
            return
        } else if index >= eachHistory.count {
            addWebView()
        } else {
            self.center.post(name: .footerViewModelWillChangeWebView, object: index)
            if self.locationIndex != index {
                self.locationIndex = index
                self.reloadFavorite()
                self.delegate?.baseViewModelDidChangeWebView()
            } else {
                log.warning("selected current webView")
            }
        }
    }
    
    private func reloadFavorite() {
        // 現在表示しているURLがお気に入りかどうか調べる
        let currentUrl = eachHistory[locationIndex].url
        if (!currentUrl.isEmpty) {
            let savedFavoriteUrls = CommonDao.s.selectAllFavorite().map({ (f) -> String in
                return f.url.domainAndPath
            })
            self.center.post(name: .headerViewModelWillChangeFavorite, object: savedFavoriteUrls.contains(currentUrl.domainAndPath))
        }
    }
}
