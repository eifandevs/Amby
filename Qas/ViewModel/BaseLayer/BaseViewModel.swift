//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class BaseViewModel {
    /// ページインサート通知用RX
    let rx_baseViewModelDidInsertWebView = PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
        .flatMap { object -> Observable<Int> in
            return Observable.just(object.at)
        }

    /// ページリロード通知用RX
    let rx_baseViewModelDidReloadWebView = PageHistoryDataModel.s.rx_pageHistoryDataModelDidReload.flatMap { _ in Observable.just(()) }
    /// ページ追加通知用RX
    let rx_baseViewModelDidAppendWebView = PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend.flatMap { _ in Observable.just(()) }
    /// ページ変更通知用RX
    let rx_baseViewModelDidChangeWebView = PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange.flatMap { _ in Observable.just(()) }
    /// ページ削除通知用RX
    let rx_baseViewModelDidRemoveWebView = PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
        .flatMap { object -> Observable<(deleteContext: String, currentContext: String?, deleteIndex: Int)> in
            return Observable.just(object)
        }
    /// ヒストリーバック通知用RX
    let rx_baseViewModelDidHistoryBackWebView = CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoBack.flatMap { _ in Observable.just(()) }
    /// ヒストリーフォワード通知用RX
    let rx_baseViewModelDidHistoryForwardWebView = CommonHistoryDataModel.s.rx_commonHistoryDataModelDidGoForward.flatMap { _ in Observable.just(()) }
    /// 検索通知用RX
    let rx_baseViewModelDidSearchWebView = OperationDataModel.s.rx_operationDataModelDidChange
        .flatMap { object -> Observable<String> in
            if object.operation == .search {
                let text = object.object as! String
                return Observable.just(text)
            } else {
                return Observable.empty()
            }
        }
    /// フォーム登録通知用RX
    let rx_baseViewModelDidRegisterAsForm = OperationDataModel.s.rx_operationDataModelDidChange
        .flatMap { object -> Observable<()> in
            if object.operation == .form {
                return Observable.just(())
            } else {
                return Observable.empty()
            }
        }
    /// 自動スクロール通知用RX
    let rx_baseViewModelDidAutoScroll = OperationDataModel.s.rx_operationDataModelDidChange
        .flatMap { object -> Observable<()> in
            if object.operation == .autoScroll {
                return Observable.just(())
            } else {
                return Observable.empty()
            }
        }
    /// 自動入力通知用RX
    let rx_baseViewModelDidAutoFill = OperationDataModel.s.rx_operationDataModelDidChange
        .flatMap { object -> Observable<()> in
            if object.operation == .autoFill {
                return Observable.just(())
            } else {
                return Observable.empty()
            }
        }
    /// スクロールアップ通知用RX
    let rx_baseViewModelDidScrollUp = OperationDataModel.s.rx_operationDataModelDidChange
        .flatMap { object -> Observable<()> in
            if object.operation == .scrollUp {
                return Observable.just(())
            } else {
                return Observable.empty()
            }
        }
    /// ホーム表示通知用RX
    let rx_baseViewModelDidGoHome = OperationDataModel.s.rx_operationDataModelDidChange
        .flatMap { object -> Observable<()> in
            if object.operation == .home {
                return Observable.just(())
            } else {
                return Observable.empty()
            }
        }

    /// リクエストURL(jsのURL)
    var currentUrl: String? {
        return PageHistoryDataModel.s.currentHistory?.url
    }

    /// 現在のコンテキスト
    var currentContext: String? {
        return PageHistoryDataModel.s.currentContext
    }

    /// 現在の位置
    var currentLocation: Int? {
        return PageHistoryDataModel.s.currentLocation
    }

    var headerFieldText: String = "" {
        didSet {
            HeaderViewDataModel.s.updateHeaderFieldText(text: headerFieldText)
        }
    }

    var reloadUrl: String {
        return headerFieldText
    }

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
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_UIApplicationWillResignActive")
                guard let `self` = self else { return }
                self.storeHistoryDataModel()
                log.eventOut(chain: "rx_UIApplicationWillResignActive")
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
        return PageHistoryDataModel.s.getMostForwardUrl(context: context)
    }

    /// 過去ページ閲覧中フラグ取得
    func getIsPastViewingPageHistoryDataModel(context: String) -> Bool {
        return PageHistoryDataModel.s.isPastViewing(context: context)
    }

    /// 前回URL取得
    func getBackUrlPageHistoryDataModel(context: String) -> String? {
        return PageHistoryDataModel.s.getBackUrl(context: context)
    }

    /// 次URL取得
    func getForwardUrlPageHistoryDataModel(context: String) -> String? {
        return PageHistoryDataModel.s.getForwardUrl(context: context)
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

    func storeFormDataModel(form: Form) {
        FormDataModel.s.store(form: form)
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
    func getPreviousCapture() -> UIImage? {
        if let currentLocation = currentLocation {
            let targetIndex = currentLocation == 0 ? PageHistoryDataModel.s.histories.count - 1 : currentLocation - 1
            let targetContext = PageHistoryDataModel.s.histories[targetIndex].context
            if let image = ThumbnailDataModel.s.getCapture(context: targetContext) {
                return image
            } else {
                return UIImage()
            }
        }

        return nil
    }

    /// 次webviewのキャプチャ取得
    func getNextCapture() -> UIImage? {
        if let currentLocation = currentLocation {
            let targetIndex = currentLocation == PageHistoryDataModel.s.histories.count - 1 ? 0 : currentLocation + 1
            let targetContext = PageHistoryDataModel.s.histories[targetIndex].context
            if let image = ThumbnailDataModel.s.getCapture(context: targetContext) {
                return image
            } else {
                return UIImage()
            }
        }

        return nil
    }

    /// ヘッダーフィールドの更新
    func reloadHeaderText() {
        if let url = currentUrl {
            headerFieldText = url
        }
    }

    /// 前WebViewに切り替え
    func goBackPageHistoryDataModel() {
        PageHistoryDataModel.s.goBack()
    }

    /// 後WebViewに切り替え
    func goNextPageHistoryDataModel() {
        PageHistoryDataModel.s.goNext()
    }

    /// 履歴保存
    func updateHistoryDataModel(context: String, url: String, title: String, operation: PageHistory.Operation) {
        if !url.isEmpty && !title.isEmpty {
            let currentUrl = self.currentUrl
            // Each History
            PageHistoryDataModel.s.update(context: context, url: url, title: title, operation: operation)
            log.debug("save page history. url: \(url)")

            // 　アプリ起動後の前回ページロード時は、履歴に保存しない
            if url != currentUrl {
                // Common History
                let common = CommonHistory(url: url, title: title, date: Date())
                // 配列の先頭に追加する
                CommonHistoryDataModel.s.insert(history: common)
                log.debug("save common history. url: \(common.url)")
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
    func deleteThumbnailDataModel(webView: EGWebView) {
        log.debug("delete thumbnail. context: \(webView.context)")
        ThumbnailDataModel.s.delete(context: webView.context)
    }

    /// 暗号化
    func encrypt(value: String) -> Data {
        return EncryptHelper.encrypt(serviceToken: AuthTokenDataModel.s.keychainServiceToken, ivToken: AuthTokenDataModel.s.keychainIvToken, value: value)!
    }

    /// 複合化
    func decrypt(value: Data) -> String {
        return EncryptHelper.decrypt(serviceToken: AuthTokenDataModel.s.keychainServiceToken, ivToken: AuthTokenDataModel.s.keychainIvToken, data: value) ?? ""
    }

    // MARK: Private Method

    private func changePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.change(context: context)
    }
}
