//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import WebKit
import RxSwift
import RxCocoa

protocol BaseViewModelDelegate: class {
    func baseViewModelDidReloadWebView()
    func baseViewModelDidAppendWebView()
    func baseViewModelDidChangeWebView()
    func baseViewModelDidRemoveWebView(context: String, pageExist: Bool, deleteIndex: Int)
    func baseViewModelDidHistoryBackWebView()
    func baseViewModelDidHistoryForwardWebView()
    func baseViewModelDidSearchWebView(text: String)
    func baseViewModelDidRegisterAsForm()
    func baseViewModelDidAutoScroll()
    func baseViewModelDidAutoInput()
}

class BaseViewModel {
    /// インサート通知用RX
    let rx_baseViewModelDidInsertWebView = PublishSubject<Int>()

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
    
    /// 自動スクロールスピード
    let autoScrollSpeed: CGFloat = 0.6

    /// Observable自動解放
    let disposeBag = DisposeBag()

    init() {
        // バックグラウンドに入るときに履歴を保存する
        center.rx.notification(.UIApplicationWillResignActive, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                self.storeHistoryDataModel()
        }
        .disposed(by: disposeBag)
        
        // webviewのリロード
        center.rx.notification(.pageHistoryDataModelDidReload, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewModel Event]: pageHistoryDataModelDidReload")
                self.delegate?.baseViewModelDidReloadWebView()
            }
            .disposed(by: disposeBag)
        
        // オペレーション監視
        center.rx.notification(.operationDataModelDidChange, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewModel Event]: operationDataModelDidChange")
                if let notification = notification.element {
                    let operation = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OPERATION] as! UserOperation
                    if operation == .autoInput {
                        self.delegate?.baseViewModelDidAutoInput()
                    } else if operation == .urlCopy {
                        UIPasteboard.general.string = self.currentUrl
                        NotificationManager.presentNotification(message: MessageConst.NOTIFICATION_COPY_URL)
                    } else if operation == .search {
                        let text = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OBJECT] as! String
                        self.delegate?.baseViewModelDidSearchWebView(text: text)
                    } else if operation == .form {
                        self.delegate?.baseViewModelDidRegisterAsForm()
                    } else if operation == .autoScroll {
                        self.delegate?.baseViewModelDidAutoScroll()
                    }
                }
            }
            .disposed(by: disposeBag)

        // webviewの削除
        center.rx.notification(.pageHistoryDataModelDidRemove, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewModel Event]: pageHistoryDataModelDidRemove")
                if let notification = notification.element {
                    let context = (notification.object as! [String: Any])["context"] as! String
                    let pageExist = (notification.object as! [String: Any])["pageExist"] as! Bool
                    let deleteIndex = (notification.object as! [String: Any])["deleteIndex"] as! Int
                    
                    self.delegate?.baseViewModelDidRemoveWebView(context: context, pageExist: pageExist, deleteIndex: deleteIndex)
                }
            }
            .disposed(by: disposeBag)
        
        // webviewヒストリバック
        center.rx.notification(.commonHistoryDataModelDidGoBack, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewModel Event]: commonHistoryDataModelDidGoBack")
                self.delegate?.baseViewModelDidHistoryBackWebView()
            }
            .disposed(by: disposeBag)
        
        // webviewヒストリフォワード
        center.rx.notification(.commonHistoryDataModelDidGoForward, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewModel Event]: commonHistoryDataModelDidGoForward")
                self.delegate?.baseViewModelDidHistoryForwardWebView()
            }
            .disposed(by: disposeBag)
        
        // ページ変更
        center.rx.notification(.pageHistoryDataModelDidChange, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewModel Event]: pageHistoryDataModelDidChange")
                self.delegate?.baseViewModelDidChangeWebView()
            }
            .disposed(by: disposeBag)
        
        // ページ挿入
        center.rx.notification(.pageHistoryDataModelDidAppend, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewModel Event]: pageHistoryDataModelDidAppend")
                self.delegate?.baseViewModelDidAppendWebView()
            }
            .disposed(by: disposeBag)

        // ページ追加
        center.rx.notification(.pageHistoryDataModelDidInsert, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewModel Event]: pageHistoryDataModelDidInsert")
                if let notification = notification.element {
                    let at = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_AT] as! Int
                    self.rx_baseViewModelDidInsertWebView.onNext(at)
                }
            }
            .disposed(by: disposeBag)
    }
    
    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: Public Method

    /// ページインデックス取得
    func getIndex(context: String) -> Int? {
        return PageHistoryDataModel.s.getIndex(context: context)
    }
    
    /// 直近URL取得
    func getMostForwardUrlPageHistoryDataModel(context: String) -> String? {
        return PageHistoryDataModel.s.getMostForwardUrl(context:context)
    }
    
    /// 過去ページ閲覧中フラグ取得
    func getPastViewingPageHistoryDataModel(context: String) -> Bool {
        return PageHistoryDataModel.s.isPastViewing(context:context)
    }
    
    /// 前回URL取得
    func getBackUrlPageHistoryDataModel(context: String) -> String? {
        return PageHistoryDataModel.s.getBackUrl(context:context)
    }
    
    /// 次URL取得
    func getForwardUrlPageHistoryDataModel(context: String) -> String? {
        return PageHistoryDataModel.s.getForwardUrl(context:context)
    }
    
    func startLoadingPageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.startLoading(context: context)
    }
    
    func endLoadingPageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.endLoading(context: context)
    }

    func endRenderingPageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.endRendering(context: context)
    }
    
    func updateProgressHeaderViewDataModel(object: CGFloat) {
        HeaderViewDataModel.s.updateProgress(progress: object)
    }
    
    func insertPageHistoryDataModel(url: String? = nil) {
        PageHistoryDataModel.s.append(url: url)
    }
    
    func insertByEventPageHistoryDataModel(url: String? = nil) {
        PageHistoryDataModel.s.insert(url: url)
    }
    
    func beginEditingHeaderViewDataModel() {
        HeaderViewDataModel.s.beginEditing(forceEditFlg: false)
    }
    
    func storeFromDataModel(webview: EGWebView) {
        FormDataModel.s.store(webView: webview)
    }

    /// baseViewControllerの状態取得
    /// ヘルプ画面表示中はfalseとなる
    func getBaseViewControllerStatus() -> Bool {
        if let baseViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController {
            return (baseViewController as! BaseViewController).isActive
        }
        return false
    }
    /// 前webviewのキャプチャ取得
    func getPreviousCapture() -> UIImage {
        let targetIndex = currentLocation == 0 ? PageHistoryDataModel.s.histories.count - 1 : currentLocation - 1
        let targetContext = PageHistoryDataModel.s.histories[targetIndex].context
        if let image = ThumbnailDataModel.s.getCapture(context: targetContext) {
            return image
        } else {
            return UIImage()
        }
    }
    
    /// 次webviewのキャプチャ取得
    func getNextCapture() -> UIImage {
        let targetIndex = currentLocation == PageHistoryDataModel.s.histories.count - 1 ? 0 : currentLocation + 1
        let targetContext = PageHistoryDataModel.s.histories[targetIndex].context
        if let image = ThumbnailDataModel.s.getCapture(context: targetContext) {
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
    
    /// 履歴保存
    func updateHistoryDataModel(context: String, url: String, title: String, operation: PageHistory.Operation) {
        if !url.isEmpty && !title.isEmpty {
            //　アプリ起動後の前回ページロード時は、履歴に保存しない
            if url != self.currentUrl {
                // Common History
                let common = CommonHistory(url: url, title: title, date: Date())
                // 配列の先頭に追加する
                CommonHistoryDataModel.s.histories.insert(common, at: 0)
                log.debug("save history. url: \(common.url)")
                
                // Each History
                PageHistoryDataModel.s.update(context: context, url: url, title: title, operation: operation)
            }
        }
        
        // ヘッダーのお気に入りアイコン更新
        if context == currentContext {
            // フロントページの保存の場合
            FavoriteDataModel.s.reload()
        }
    }
    
    /// 閲覧、ページ履歴の永続化
    func storeHistoryDataModel() {
        CommonHistoryDataModel.s.store()
        PageHistoryDataModel.s.store()
    }
    
    /// 検索履歴の永続化
    func storeSearchHistoryDataModel(title: String) {
        SearchHistoryDataModel.s.store(histories: [SearchHistory(title: title, date: Date())])
    }
    
    /// ページ履歴の永続化
    func storePageHistoryDataModel() {
        PageHistoryDataModel.s.store()
    }
    
    /// サムネイルの削除
    func deleteThumbnail(webView: EGWebView) {
        log.debug("delete thumbnail. context: \(webView.context)")
        ThumbnailDataModel.s.delete(context: webView.context)
    }
    
// MARK: Private Method
    private func changePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.change(context: context)
    }
}
