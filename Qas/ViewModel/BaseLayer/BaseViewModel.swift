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
    /// リクエストURL(jsのURL)
    var currentUrl: String {
        return PageHistoryDataModel.s.currentHistory.url
    }
    
    /// 現在のコンテキスト
    var currentContext: String? {
        return PageHistoryDataModel.s.currentContext
    }

    /// 現在の位置
    var currentLocation: Int {
        return PageHistoryDataModel.s.currentLocation
    }
    
    var headerFieldText: String = "" {
        didSet {

            center.post(name: .headerViewDataModelHeaderFieldTextDidUpdate, object: headerFieldText)
        }
    }
    
    var reloadUrl: String {
        return headerFieldText
    }
    
    weak var delegate: BaseViewModelDelegate?
    
    /// 最新のリクエストURL(wv.url)。エラーが発生した時用
    var latestRequestUrl: String = ""
    
    /// webviewの数
    var webViewCount: Int {
        return PageHistoryDataModel.s.histories.count
    }
    
    /// 通知センター
    private let center = NotificationCenter.default
    
    /// 自動スクロールのタイムインターバル
    var autoScrollInterval: CGFloat {
        return CGFloat(UserDefaults.standard.float(forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL))
    }
    
    let autoScrollSpeed: CGFloat = 0.6

    init() {
        // バックグラウンドに入るときに履歴を保存する
        center.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            self.storeHistory()
        }

        // 閲覧履歴の削除
        center.addObserver(forName: .baseViewModelWillDeleteHistory, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillDeleteHistory")
            CommonHistoryDataModel.s.histories = []
        }
        
        // 初期化
        center.addObserver(forName: .baseViewModelWillInitialize, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillInitialize")
            CommonHistoryDataModel.s.histories = []
            PageHistoryDataModel.s.histories = []
        }
        
        // webviewのコピー
        center.addObserver(forName: .baseViewModelWillCopyWebView, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: baseViewModelWillCopyWebView")
//            PageHistoryDataModel.s.histories.append(PageHistory(url: PageHistoryDataModel.s.histories[self.currentLocation].url, title: PageHistoryDataModel.s.histories[self.currentLocation].title))
//            self.center.post(name: .footerViewModelWillAddWebView, object: PageHistoryDataModel.s.histories[self.currentLocation])
//            self.delegate?.baseViewModelDidAddWebView()
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
//            let index = ((notification.object as? Int) != nil) ? notification.object as! Int : self.currentLocation
//            let isFrontDelete = self.currentLocation == index
//            self.center.post(name: .footerViewModelWillRemoveWebView, object: index)
//            if ((index != 0 && self.currentLocation == index && index == PageHistoryDataModel.s.histories.count - 1) || (index < self.currentLocation)) {
//                // indexの調整
//                PageHistoryDataModel.s.currentLocation = self.currentLocation - 1
//            }
//            PageHistoryDataModel.s.histories.remove(at: index)
//            self.reloadFavorite()
//            self.delegate?.baseViewModelDidRemoveWebView(index: index, isFrontDelete: isFrontDelete)
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
            NotificationManager.presentNotification(message: MessageConst.NOTIFICATION_COPY_URL)
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
        
        // ページ変更
        center.addObserver(forName: .pageHistoryDataModelDidChange, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: pageHistoryDataModelDidChange")
            self.delegate?.baseViewModelDidChangeWebView()
        }
        
        // ページ追加
        center.addObserver(forName: .pageHistoryDataModelDidInsert, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseView Event]: pageHistoryDataModelDidInsert")
            self.delegate?.baseViewModelDidAddWebView()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: Public Method

    func startLoadingPageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.startLoading(context: context)
    }
    
    func endLoadingPageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.endLoading(context: context)
    }

    func updateProgressHeaderViewDataModel(object: CGFloat) {
        HeaderViewDataModel.s.updateProgress(progress: object)
    }
    
    func insertPageHistoryDataModel(url: String? = nil) {
        PageHistoryDataModel.s.insert(url: url)
    }
    
//    func addWebView(url: String? = nil) {
//        if let url = url {
//            PageHistoryDataModel.s.histories.append(PageHistory(url: url))
//        } else {
//            PageHistoryDataModel.s.histories.append(PageHistory())
//        }
//        PageHistoryDataModel.s.currentLocation = PageHistoryDataModel.s.histories.count - 1
//        self.reloadFavorite()
//        self.center.post(name: .footerViewModelWillAddWebView, object: PageHistoryDataModel.s.histories.last!)
//        self.delegate?.baseViewModelDidAddWebView()
//    }
    
    func beginEditingHeaderViewDataModel() {
        HeaderViewDataModel.s.beginEditing(forceEditFlg: false)
    }
    
    /// 前webviewのキャプチャ取得
    func getPreviousCapture() -> UIImage {
        let targetIndex = currentLocation == 0 ? PageHistoryDataModel.s.histories.count - 1 : currentLocation - 1
        let targetContext = PageHistoryDataModel.s.histories[targetIndex].context
        if let image = ThumbnailDataModel.getCapture(context: targetContext) {
            return image
        } else {
            return UIImage()
        }
    }
    
    /// 次webviewのキャプチャ取得
    func getNextCapture() -> UIImage {
        let targetIndex = currentLocation == PageHistoryDataModel.s.histories.count - 1 ? 0 : currentLocation + 1
        let targetContext = PageHistoryDataModel.s.histories[targetIndex].context
        if let image = ThumbnailDataModel.getCapture(context: targetContext) {
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
        PageHistoryDataModel.s.goBack()
    }
    
    /// 後WebViewに切り替え
    func changeNextWebView() {
        PageHistoryDataModel.s.goNext()
    }
    
    func saveHistory(wv: EGWebView) {
        if let requestUrl = wv.requestUrl, let requestTitle = wv.requestTitle, !requestTitle.isEmpty {
            //　アプリ起動後の前回ページロード時は、履歴に保存しない
            if requestUrl != self.currentUrl {
                // Common History
                let common = CommonHistory(url: requestUrl, title: requestTitle, date: Date())
                // 配列の先頭に追加する
                CommonHistoryDataModel.s.histories.insert(common, at: 0)
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
            // ヘッダーのお気に入りアイコン更新
            if wv.context == currentContext {
                // フロントページの保存の場合
                FavoriteDataModel.s.reload()
            }
        }
    }
    
    /// 閲覧、ページ履歴の永続化
    func storeHistory() {
        CommonHistoryDataModel.s.store()
        PageHistoryDataModel.s.store()
    }
    
    /// 検索履歴の永続化
    func storeSearchHistory(title: String) {
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: title, date: Date())])
    }
    
    /// ページ履歴の永続化
    func storePageHistory() {
        PageHistoryDataModel.s.store()
    }
    
    /// サムネイルの削除
    func deleteThumbnail(webView: EGWebView) {
        log.debug("delete thumbnail. context: \(webView.context)")
        ThumbnailDataModel.delete(context: webView.context)
    }
    
// MARK: Private Method
    private func changePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.change(context: context)
    }
    
//    private func changeWebView(index: Int) {
//        let targetIndex = {() -> Int in
//            if index < 0 {
//                return PageHistoryDataModel.s.histories.count - 1
//            } else if index >= PageHistoryDataModel.s.histories.count {
//                return 0
//            } else {
//                return index
//            }
//        }()
//        self.center.post(name: .footerViewModelWillChangeWebView, object: targetIndex)
//        if self.currentLocation != targetIndex {
//            PageHistoryDataModel.s.currentLocation = targetIndex
//            self.reloadFavorite()
//            self.delegate?.baseViewModelDidChangeWebView()
//        } else {
//            log.warning("selected current webView")
//        }
//    }
}
