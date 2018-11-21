//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

final class BaseViewModel {
    struct TouchState: OptionSet {
        let rawValue: Int
        /// タッチ中フラグ
        static let isTouching = TouchState(rawValue: 1 << 0)
        /// アニメーション中フラグ
        static let isAnimating = TouchState(rawValue: 1 << 1)
        /// 自動入力ダイアログ表示済みフラグ
        static let isDoneAutoFill = TouchState(rawValue: 1 << 2)
        /// スクロール中フラグ
        static let isScrolling = TouchState(rawValue: 1 << 3)
        /// スワイプでページ切り替えを検知したかどうかのフラグ
        static let isChangingFront = TouchState(rawValue: 1 << 4)
        /// 新規タブイベント選択中
        static let isSelectingNewTabEvent = TouchState(rawValue: 1 << 5)
    }

    /// 状態管理
    var state: TouchState = []

    enum Action {
        case insert
        case reload
        case append
        case change
        case remove
        case historyBack
        case historyForward
        case trend
        case sourceCode
        case issue
        case load
        case form
        case autoScroll
        case autoInput
        case scrollUp
        case grep
    }

    let rx_action = PublishSubject<Action>()

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
    let rx_baseViewModelDidLoadSourceCode = SourceCodeUseCase.s.rx_sourceCodeUseCaseDidRequestOpen
        .flatMap { url -> Observable<String> in
            return Observable.just(url)
        }
    /// Issue表示リクエスト通知用RX
    let rx_baseViewModelDidLoadIssue = ReportUseCase.s.rx_reportUseCaseDidRequestLoad
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
        .flatMap { searchText -> Observable<String> in
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
        .flatMap { text -> Observable<String> in
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
    var currentTabCount: Int {
        return TabUseCase.s.currentTabCount
    }

    /// 通知センター
    private let center = NotificationCenter.default

    /// 自動スクロールのタイムインターバル
    var autoScrollInterval: CGFloat {
        return ScrollUseCase.s.autoScrollInterval
    }

    /// 新規ウィンドウ許諾
    var newWindowConfirm: Bool {
        return SettingUseCase.s.newWindowConfirm
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

    /// yポジションの最大最小値
    let positionY: (max: CGFloat, min: CGFloat) = (AppConst.BASE_LAYER.HEADER_HEIGHT, AppConst.DEVICE.STATUS_BAR_HEIGHT)

    /// 現在のスワイプ方向
    var swipeDirection: EdgeSwipeDirection = .none

    /// Observable自動解放
    let disposeBag = DisposeBag()

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public Method

    /// エッジスワイプ判定
    func isEdgeSwiped(touchPoint: CGPoint) -> Bool {
        return (swipeDirection == .left && touchPoint.x > AppConst.FRONT_LAYER.EDGE_SWIPE_EREA + 20) ||
            (swipeDirection == .right && touchPoint.x < AppConst.DEVICE.DISPLAY_SIZE.width - AppConst.FRONT_LAYER.EDGE_SWIPE_EREA - 20)
    }

    /// スワイプ方向取得
    func readySwipeDirection(touchBeganPoint: CGPoint?) {
        if let touchBeganPoint = touchBeganPoint {
            if touchBeganPoint.x < AppConst.FRONT_LAYER.EDGE_SWIPE_EREA {
                swipeDirection = .left
            } else if touchBeganPoint.x > AppConst.DEVICE.DISPLAY_SIZE.width - AppConst.FRONT_LAYER.EDGE_SWIPE_EREA {
                swipeDirection = .right
            } else {
                swipeDirection = .none
            }
        } else {
            swipeDirection = .none
        }
    }

    func insertTab(url: String? = nil) {
        TabUseCase.s.insert(url: url)
    }

    /// ページインデックス取得
    func getTabIndex(context: String) -> Int? {
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
        return touchPoint.y < (AppConst.DEVICE.DISPLAY_SIZE.height / 2) - AppConst.BASE_LAYER.HEADER_HEIGHT
    }

    /// 前webviewのキャプチャ取得
    func getPreviousCapture() -> UIImage? {
        if let currentLocation = currentLocation {
            let targetIndex = currentLocation == 0 ? currentTabCount - 1 : currentLocation - 1
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
            let targetIndex = currentLocation == currentTabCount - 1 ? 0 : currentLocation + 1
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

    /// サムネイルの削除
    func deleteThumbnail(context: String) {
        ThumbnailUseCase.s.delete(context: context)
    }

    /// 暗号化
    func encrypt(value: String) -> Data {
        return EncryptHelper.encrypt(value: value)
    }

    /// 複合化
    func decrypt(value: Data) -> String {
        return EncryptHelper.decrypt(data: value)
    }
}
