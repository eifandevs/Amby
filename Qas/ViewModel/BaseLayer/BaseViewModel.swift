//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
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
    var locationIndex: Int {
        return PageHistoryDataModel.s.locationIndex
    }
    // リクエストURL(jsのURL)
    var currentUrl: String {
        return PageHistoryDataModel.s.currentUrl
    }
    
    // 現在のコンテキスト
    var currentContext: String? {
        return PageHistoryDataModel.s.currentContext
    }
    
    var headerFieldText: String = "" {
        didSet {
            center.post(name: .headerViewModelWillChangeField, object: headerFieldText)
        }
    }
    
    var reloadUrl: String {
        return headerFieldText
    }
    
    weak var delegate: BaseViewModelDelegate?
    
    // 最新のリクエストURL(wv.url)。エラーが発生した時用
    var latestRequestUrl: String = ""
    
    // webviewの数
    var webViewCount: Int {
        return PageHistoryDataModel.s.histories.count
    }
    
    // 全てのwebViewの履歴
    private var commonHistory: [CommonHistoryItem] = []
    
    // 通知センター
    private let center = NotificationCenter.default
    
    var isPrivateMode: Bool? {
        return PageHistoryDataModel.s.histories.count > locationIndex ? PageHistoryDataModel.s.histories[locationIndex].isPrivate == "true" : false
    }
    
    // 自動スクロールのタイムインターバル
    var autoScrollInterval: CGFloat {
        return CGFloat(UserDefaults.standard.float(forKey: AppConst.autoScrollIntervalKey))
    }
    
    let autoScrollSpeed: CGFloat = 0.6
    
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
            PageHistoryDataModel.s.histories = []
        }
        
        // webviewのコピー
        center.addObserver(forName: .baseViewModelWillCopyWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillCopyWebView")
            PageHistoryDataModel.s.histories.append(PageHistory(url: PageHistoryDataModel.s.histories[self.locationIndex].url, title: PageHistoryDataModel.s.histories[self.locationIndex].title))
            PageHistoryDataModel.s.locationIndex = PageHistoryDataModel.s.histories.count - 1
            self.center.post(name: .footerViewModelWillAddWebView, object: PageHistoryDataModel.s.histories[self.locationIndex])
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
        // 履歴の永続化
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
            if ((index != 0 && self.locationIndex == index && index == PageHistoryDataModel.s.histories.count - 1) || (index < self.locationIndex)) {
                // indexの調整
                PageHistoryDataModel.s.locationIndex = self.locationIndex - 1
            }
            PageHistoryDataModel.s.histories.remove(at: index)
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
            UIPasteboard.general.string = self.currentUrl
            NotificationManager.presentNotification(message: "URLをコピーしました")
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
            if (!PageHistoryDataModel.s.histories[self.locationIndex].url.isEmpty && !PageHistoryDataModel.s.histories[self.locationIndex].title.isEmpty) {
                let fd = Favorite()
                fd.title = PageHistoryDataModel.s.histories[self.locationIndex].title
                fd.url = PageHistoryDataModel.s.histories[self.locationIndex].url
                
                if let favorite = FavoriteDataModel.select(url: fd.url).first {
                    // すでに登録済みの場合は、お気に入りから削除する
                    FavoriteDataModel.delete(favorites: [favorite])
                    self.center.post(name: .headerViewModelWillChangeFavorite, object: ["url": fd.url])
                } else {
                    FavoriteDataModel.insert(favorites: [fd])
                    // ヘッダーのお気に入りアイコン更新。headerViewModelに通知する
                    self.center.post(name: .headerViewModelWillChangeFavorite, object: ["url": fd.url])
                    NotificationManager.presentNotification(message: "お気に入りに登録しました")
                }
            } else {
                NotificationManager.presentNotification(message: "登録情報を取得できませんでした")
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
        center.post(name: .footerViewModelWillLoad, object: PageHistoryDataModel.s.histories)
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
            PageHistoryDataModel.s.histories.append(PageHistory(url: url, isPrivate: isPrivate))
        } else {
            PageHistoryDataModel.s.histories.append(PageHistory(isPrivate: isPrivate))
        }
        PageHistoryDataModel.s.locationIndex = PageHistoryDataModel.s.histories.count - 1
        self.reloadFavorite()
        self.center.post(name: .footerViewModelWillAddWebView, object: PageHistoryDataModel.s.histories.last!)
        self.delegate?.baseViewModelDidAddWebView()
    }
    
    func notifyBeginEditing() {
        center.post(name: .headerViewModelWillBeginEditing, object: false)
    }
    
    /// 前webviewのキャプチャ取得
    func getPreviousCapture() -> UIImage {
        let targetIndex = locationIndex == 0 ? PageHistoryDataModel.s.histories.count - 1 : locationIndex - 1
        let targetContext = PageHistoryDataModel.s.histories[targetIndex].context
        if let image = CommonDao.s.getCaptureImage(context: targetContext) {
            return image
        } else {
            return UIImage()
        }
    }
    
    func getNextCapture() -> UIImage {
        let targetIndex = locationIndex == PageHistoryDataModel.s.histories.count - 1 ? 0 : locationIndex + 1
        let targetContext = PageHistoryDataModel.s.histories[targetIndex].context
        if let image = CommonDao.s.getCaptureImage(context: targetContext) {
            return image
        } else {
            return UIImage()
        }
    }
    
    /// ヘッダーフィールドの更新
    func reloadHeaderText() {
        headerFieldText = currentUrl
    }
    
    /// 前WebViewに切り替え
    func changePreviousWebView() {
        changeWebView(index: locationIndex - 1)
    }
    
    /// 後WebViewに切り替え
    func changeNextWebView() {
        changeWebView(index: locationIndex + 1)
    }
    
    func saveHistory(wv: EGWebView) {
        if let requestUrl = wv.requestUrl, let requestTitle = wv.requestTitle, !requestTitle.isEmpty {
            // ヘッダーのお気に入りアイコン更新。headerViewModelに通知する
            if wv.context == currentContext {
                // フロントページの保存の場合
                center.post(name: .headerViewModelWillChangeFavorite, object: ["url": requestUrl])
            }
            if !isPrivateMode! {
                //　アプリ起動後の前回ページロード時は、履歴に保存しない
                if requestUrl != self.currentUrl {
                    // Common History
                    let common = CommonHistoryItem(url: requestUrl, title: requestTitle, date: Date())
                    // 配列の先頭に追加する
                    commonHistory.insert(common, at: 0)
                    log.debug("save history. url: \(common.url)")
                    
                    // Each History
                    for history in PageHistoryDataModel.s.histories {
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
        PageHistoryDataModel.s.store()
        commonHistory = []
    }
    
    func storePageHistory() {
        PageHistoryDataModel.s.store()
    }
    
// MARK: Private Method
    private func changeWebView(index: Int) {
        let targetIndex = {() -> Int in
            if index < 0 {
                return PageHistoryDataModel.s.histories.count - 1
            } else if index >= PageHistoryDataModel.s.histories.count {
                return 0
            } else {
                return index
            }
        }()
        self.center.post(name: .footerViewModelWillChangeWebView, object: targetIndex)
        if self.locationIndex != targetIndex {
            PageHistoryDataModel.s.locationIndex = targetIndex
            self.reloadFavorite()
            self.delegate?.baseViewModelDidChangeWebView()
        } else {
            log.warning("selected current webView")
        }
    }
    
    private func reloadFavorite() {
        // 現在表示しているURLがお気に入りかどうか調べる
        if let history = PageHistoryDataModel.s.histories[safe: locationIndex] {
            if (!history.url.isEmpty) {
                self.center.post(name: .headerViewModelWillChangeFavorite, object: ["url": history.url])
            }
        }
    }
}
