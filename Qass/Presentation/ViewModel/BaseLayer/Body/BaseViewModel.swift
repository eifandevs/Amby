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
    let rx_baseViewModelDidInsertWebView = TabUseCase.s.rx_tabUseCaseDidInsert
        .flatMap { at -> Observable<Int> in
            return Observable.just(at)
        }

    /// ページリロード通知用RX
    let rx_baseViewModelDidReloadWebView = TabUseCase.s.rx_tabUseCaseDidReload.flatMap { _ in Observable.just(()) }
    /// ページ追加通知用RX
    let rx_baseViewModelDidAppendWebView = TabUseCase.s.rx_tabUseCaseDidAppend.flatMap { _ in Observable.just(()) }
    /// ページ変更通知用RX
    let rx_baseViewModelDidChangeWebView = TabUseCase.s.rx_tabUseCaseDidChange.flatMap { _ in Observable.just(()) }
    /// ページ削除通知用RX
    let rx_baseViewModelDidRemoveWebView = TabUseCase.s.rx_tabUseCaseDidRemove
        .flatMap { object -> Observable<(deleteContext: String, currentContext: String?, deleteIndex: Int)> in
            return Observable.just(object)
        }
    /// ヒストリーバック通知用RX
    let rx_baseViewModelDidHistoryBackWebView = HistoryUseCase.s.rx_historyUseCaseDidRequestHistoryBack.flatMap { _ in Observable.just(()) }
    /// ヒストリーフォワード通知用RX
    let rx_baseViewModelDidHistoryForwardWebView = HistoryUseCase.s.rx_historyUseCaseDidRequestHistoryForward.flatMap { _ in Observable.just(()) }
    /// トレンド表示リクエスト通知用RX
    let rx_baseViewModelDidLoadTrend = TrendUseCase.s.rx_trendUseCaseDidRequestLoad
        .flatMap { url -> Observable<String> in
            return Observable.just(url)
        }
    /// ソースコード表示リクエスト通知用RX
    let rx_baseViewModelDidLoadSourceCode = SourceCodeUseCase.s.rx_sourceCodeUseCaseDidRequestLoad
        .flatMap { url -> Observable<String> in
            return Observable.just(url)
    }
    /// ロードリクエスト通知用RX(Favorite)
    let rx_baseViewModelDidLoadFavorite = FavoriteUseCase.s.rx_favoriteUseCaseDidRequestLoad
        .flatMap { url -> Observable<String> in
            return Observable.just(url)
    }
    /// ロードリクエスト通知用RX(Form)
    let rx_baseViewModelDidLoadForm = FormUseCase.s.rx_formUseCaseDidRequestLoad
        .flatMap { url -> Observable<String> in
            return Observable.just(url)
    }
    /// ロードリクエスト通知用RX(History)
    let rx_baseViewModelDidLoadHistory = HistoryUseCase.s.rx_historyUseCaseDidRequestLoad
        .flatMap { url -> Observable<String> in
            return Observable.just(url)
    }
    /// ロードリクエスト通知用RX
    let rx_baseViewModelDidSearchWebView = SearchUseCase.s.rx_searchUseCaseDidRequestLoad
        .flatMap { text -> Observable<String> in
            let searchText = { () -> String in
                if text.isValidUrl {
                    return text
                } else {
                    // 検索ワードによる検索
                    // 閲覧履歴を保存する
                    SearchHistoryDataModel.s.store(text: text)

                    let encodedText = "\(HttpConst.URL.SEARCH_PATH)\(text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)!)"
                    return encodedText
                }
            }()
            ProgressDataModel.s.updateText(text: searchText)

            return Observable.just(searchText)
        }
    /// フォーム登録通知用RX
    let rx_baseViewModelDidRegisterAsForm = FormUseCase.s.rx_formUseCaseDidRequestRegisterForm
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }
    /// 自動スクロール通知用RX
    let rx_baseViewModelDidAutoScroll = ScrollUseCase.s.rx_scrollUseCaseDidRequestAutoScroll
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }
    /// 自動入力通知用RX
    let rx_baseViewModelDidAutoFill = FormUseCase.s.rx_formUseCaseDidRequestAutoFill
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }
    /// スクロールアップ通知用RX
    let rx_baseViewModelDidScrollUp = ScrollUseCase.s.rx_scrollUseCaseDidRequestScrollUp
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }
    /// 全文検索通知用RX
    let rx_baseViewModelDidGrep = GrepUseCase.s.rx_grepUseCaseDidRequestGrep
        .flatMap { text -> Observable<(String)> in
            if !text.isEmpty {
                return Observable.just(text)
            }

            return Observable.empty()
        }

    /// リクエストURL(jsのURL)
    var currentUrl: String? {
        return TabUseCase.s.currentUrl
    }

    /// 現在のコンテキスト
    var currentContext: String? {
        return TabUseCase.s.currentContext
    }

    /// 現在の位置
    var currentLocation: Int? {
        return TabUseCase.s.currentLocation
    }

    /// webviewの数
    var currentPageCount: Int {
        return TabUseCase.s.currentPageCount
    }

    /// 通知センター
    private let center = NotificationCenter.default

    /// 自動スクロールのタイムインターバル
    var autoScrollInterval: CGFloat {
        return CGFloat(AppDataModel.s.autoScrollInterval)
    }

    /// baseViewControllerの状態取得
    /// ヘルプ画面表示中はfalseとなる
    var canSwipe: Bool {
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let baseViewController = delegate.window?.rootViewController {
            if let baseViewController = baseViewController as? BaseViewController {
                return !baseViewController.isPresented
            } else {
                return false
            }
        }
        return false
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
                self.store()
                log.eventOut(chain: "rx_UIApplicationWillResignActive")
            }
            .disposed(by: disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public Method

    func insert(url: String? = nil) {
        TabUseCase.s.insert(url: url)
    }

    /// ページインデックス取得
    func getIndex(context: String) -> Int? {
        return TabUseCase.s.getIndex(context: context)
    }

    /// 直近URL取得
    func getMostForwardUrl(context: String) -> String? {
        return TabUseCase.s.getMostForwardUrl(context: context)
    }

    /// 過去ページ閲覧中フラグ取得
    func getIsPastViewing(context: String) -> Bool? {
        return TabUseCase.s.getIsPastViewing(context: context)
    }

    /// 前回URL取得
    func getBackUrl(context: String) -> String? {
        return TabUseCase.s.getBackUrl(context: context)
    }

    /// 次URL取得
    func getForwardUrl(context: String) -> String? {
        return TabUseCase.s.getForwardUrl(context: context)
    }

    func startLoading(context: String) {
        TabUseCase.s.startLoading(context: context)
    }

    func endLoading(context: String) {
        TabUseCase.s.endLoading(context: context)
    }

    func endRendering(context: String) {
        TabUseCase.s.endRendering(context: context)
    }

    func updateProgress(progress: CGFloat) {
        ProgressUseCase.s.updateProgress(progress: progress)
    }

    /// 検索開始
    func beginSearching() {
        SearchUseCase.s.beginAtHeader()
    }

    func storeForm(form: Form) {
        FormUseCase.s.store(form: form)
    }

    /// スワイプが履歴移動スワイプかを判定
    func isHistorySwipe(touchPoint: CGPoint) -> Bool {
        return touchPoint.y < (DeviceConst.DEVICE.DISPLAY_SIZE.height / 2) - AppConst.BASE_LAYER.HEADER_HEIGHT
    }

    /// 前webviewのキャプチャ取得
    func getPreviousCapture() -> UIImage? {
        if let currentLocation = currentLocation {
            let targetIndex = currentLocation == 0 ? currentPageCount - 1 : currentLocation - 1
            if let targetContext = TabUseCase.s.getHistory(index: targetIndex)?.context {
                if let image = ThumbnailUseCase.s.getCapture(context: targetContext) {
                    return image
                } else {
                    return UIImage()
                }
            } else {
                return nil
            }
        }

        return nil
    }

    /// 次webviewのキャプチャ取得
    func getNextCapture() -> UIImage? {
        if let currentLocation = currentLocation {
            let targetIndex = currentLocation == currentPageCount - 1 ? 0 : currentLocation + 1
            if let targetContext = TabUseCase.s.getHistory(index: targetIndex)?.context {
                if let image = ThumbnailUseCase.s.getCapture(context: targetContext) {
                    return image
                } else {
                    return UIImage()
                }
            } else {
                return nil
            }
        }

        return nil
    }

    /// reload ProgressDataModel
    func reloadProgress() {
        ProgressUseCase.s.reloadProgress()
    }

    /// update text in ProgressDataModel
    func updateProgressText(text: String) {
        ProgressUseCase.s.updateText(text: text)
    }

    /// 前WebViewに切り替え
    func goBackTab() {
        TabUseCase.s.goBack()
    }

    /// 後WebViewに切り替え
    func goNextTab() {
        TabUseCase.s.goNext()
    }

    /// 前ページに戻る
    func historyBack() {
        HistoryUseCase.s.goBack()
    }

    /// 次ページに進む
    func historyForward() {
        HistoryUseCase.s.goForward()
    }

    /// create thumbnail folder
    func createThumbnailFolder(context: String) {
        ThumbnailUseCase.s.createFolder(context: context)
    }

    /// write thumbnail data
    func writeThumbnailData(context: String, data: Data) {
        ThumbnailUseCase.s.write(context: context, data: data)
    }

    /// update url in page history
    func updatePageUrl(context: String, url: String, operation: PageHistory.Operation) {
        TabUseCase.s.updateUrl(context: context, url: url, operation: operation)
    }

    /// update title in page history
    func updatePageTitle(context: String, title: String) {
        TabUseCase.s.updateTitle(context: context, title: title)
    }

    /// update common history
    func insertHistory(url: URL?, title: String?) {
        HistoryUseCase.s.insert(url: url, title: title)
    }

    /// 閲覧、ページ履歴の永続化
    func store() {
        HistoryUseCase.s.store()
        TabUseCase.s.store()
    }

    /// サムネイルの削除
    func deleteThumbnail(context: String) {
        ThumbnailUseCase.s.delete(context: context)
    }

    /// 暗号化
    func encrypt(value: String) -> Data {
        return EncryptUseCase.s.encrypt(value: value)
    }

    /// 複合化
    func decrypt(value: Data) -> String {
        return EncryptUseCase.s.decrypt(value: value)
    }
}
