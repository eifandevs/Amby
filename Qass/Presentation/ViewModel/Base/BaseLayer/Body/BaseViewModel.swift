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
        case insert(at: Int)
        case reload
        case append
        case change
        case remove((deleteContext: String, currentContext: String?, deleteIndex: Int))
        case historyBack
        case historyForward
        case load(url: String)
        case form
        case autoScroll
        case autoFill
        case scrollUp
        case grep(text: String)
    }

    let rx_action = PublishSubject<Action>()

    let webViewService = WebViewService()

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

    init() {
        setupRx()
    }

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }

    func setupRx() {
        // ロード要求監視
        Observable.merge([
            TrendUseCase.s.rx_trendUseCaseDidRequestLoad,
            SourceCodeUseCase.s.rx_sourceCodeUseCaseDidRequestLoad,
            ReportUseCase.s.rx_reportUseCaseDidRequestLoad,
            FavoriteUseCase.s.rx_favoriteUseCaseDidRequestLoad,
            HistoryUseCase.s.rx_historyUseCaseDidRequestLoad,
            SearchUseCase.s.rx_searchUseCaseDidRequestLoad
        ]).subscribe { [weak self] url in
            log.eventIn(chain: "rx_load")
            guard let `self` = self, let url = url.element else { return }
            self.rx_action.onNext(Action.load(url: url))
            log.eventOut(chain: "rx_load")
        }
        .disposed(by: disposeBag)

        // タブインサート監視
        TabUseCase.s.rx_tabUseCaseDidInsert
            .subscribe { [weak self] at in
                log.eventIn(chain: "rx_tabUseCaseDidInsert")
                guard let `self` = self, let at = at.element else { return }
                self.rx_action.onNext(Action.insert(at: at))
                log.eventOut(chain: "rx_tabUseCaseDidInsert")
            }
            .disposed(by: disposeBag)

        // リロード通知監視
        TabUseCase.s.rx_tabUseCaseDidReload
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_tabUseCaseDidReload")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.reload)
                log.eventOut(chain: "rx_tabUseCaseDidReload")
            }
            .disposed(by: disposeBag)

        // タブ追加監視
        TabUseCase.s.rx_tabUseCaseDidAppend
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_tabUseCaseDidAppend")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.append)
                log.eventOut(chain: "rx_tabUseCaseDidAppend")
            }
            .disposed(by: disposeBag)

        // タブ変更監視
        TabUseCase.s.rx_tabUseCaseDidChange
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_tabUseCaseDidChange")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.change)
                log.eventOut(chain: "rx_tabUseCaseDidChange")
            }
            .disposed(by: disposeBag)

        // タブ削除監視
        TabUseCase.s.rx_tabUseCaseDidRemove
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_tabUseCaseDidRemove")
                guard let `self` = self, let object = object.element else { return }
                self.rx_action.onNext(Action.remove(object))
                log.eventOut(chain: "rx_tabUseCaseDidRemove")
            }
            .disposed(by: disposeBag)

        // ヒストリーバック監視
        HistoryUseCase.s.rx_historyUseCaseDidRequestHistoryBack
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_historyUseCaseDidRequestHistoryBack")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.historyBack)
                log.eventOut(chain: "rx_historyUseCaseDidRequestHistoryBack")
            }
            .disposed(by: disposeBag)

        // ヒストリーフォワード監視
        HistoryUseCase.s.rx_historyUseCaseDidRequestHistoryForward
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_historyUseCaseDidRequestHistoryForward")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.historyForward)
                log.eventOut(chain: "rx_historyUseCaseDidRequestHistoryForward")
            }
            .disposed(by: disposeBag)

        // フォーム登録監視
        FormUseCase.s.rx_formUseCaseDidRequestRegisterForm
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_formUseCaseDidRequestRegisterForm")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.form)
                log.eventOut(chain: "rx_formUseCaseDidRequestRegisterForm")
            }
            .disposed(by: disposeBag)

        // 自動スクロール監視
        ScrollUseCase.s.rx_scrollUseCaseDidRequestAutoScroll
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_scrollUseCaseDidRequestAutoScroll")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.autoScroll)
                log.eventOut(chain: "rx_scrollUseCaseDidRequestAutoScroll")
            }
            .disposed(by: disposeBag)

        // 自動入力監視
        FormUseCase.s.rx_formUseCaseDidRequestAutoFill
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_formUseCaseDidRequestAutoFill")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.autoFill)
                log.eventOut(chain: "rx_formUseCaseDidRequestAutoFill")
            }
            .disposed(by: disposeBag)

        // スクロールアップ監視
        ScrollUseCase.s.rx_scrollUseCaseDidRequestScrollUp
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_scrollUseCaseDidRequestScrollUp")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.scrollUp)
                log.eventOut(chain: "rx_scrollUseCaseDidRequestScrollUp")
            }
            .disposed(by: disposeBag)

        // 全文検索監視
        GrepUseCase.s.rx_grepUseCaseDidRequestGrep
            .subscribe { [weak self] word in
                log.eventIn(chain: "rx_grepUseCaseDidRequestGrep")
                guard let `self` = self, let word = word.element else { return }
                self.rx_action.onNext(Action.grep(text: word))
                log.eventOut(chain: "rx_grepUseCaseDidRequestGrep")
            }
            .disposed(by: disposeBag)
    }

    // MARK: Public Method

    /// AppStore要求の場合開く
    func openAppIfAppStoreRequest(url: URL) -> Bool {
        let isAppStoreUrl = url.absoluteString.range(of: AppConst.URL.ITUNES_STORE) != nil ||
            !url.absoluteString.hasPrefix("about:") && !url.absoluteString.hasPrefix("http:") && !url.absoluteString.hasPrefix("https:") && !url.absoluteString.hasPrefix("file:")

        if isAppStoreUrl {
            log.warning("open url. url: \(url)")
            if UIApplication.shared.canOpenURL(url) {
                NotificationService.presentActionSheet(title: "", message: MessageConst.ALERT.OPEN_COMFIRM, completion: {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }, cancel: nil)
            } else {
                log.warning("cannot open url. url: \(url)")
            }

            return true
        }

        return false
    }

    /// 新規ウィンドウイベント受信
    func insertTabByReceiveNewWindowEvent(url: String) {
        if newWindowConfirm {
            insertTab(url: url)
        } else {
            state.insert(.isSelectingNewTabEvent)

            // 150文字以上は省略
            let message = url.count > 50 ? String(url.prefix(200)) + "..." : url
            NotificationService.presentActionSheet(title: MessageConst.NOTIFICATION.NEW_TAB, message: message, completion: {
                self.state.remove(.isSelectingNewTabEvent)
                self.insertTab(url: url)
            }, cancel: {
                self.state.remove(.isSelectingNewTabEvent)
            })
        }
    }

    /// サムネイル保存
    func saveThumbnailAndEndRendering(webView: EGWebView) {
        log.debug("save thumbnail. context: \(webView.context)")

        // サムネイルを保存
        DispatchQueue.mainSyncSafe {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                webView.takeSnapshot(with: nil) { [weak self] image, error in
                    guard let `self` = self else { return }
                    if let img = image {
                        let pngImageData = UIImagePNGRepresentation(img)
                        let context = webView.context

                        if let pngImageData = pngImageData {
                            self.writeThumbnailData(context: context, data: pngImageData)
                        } else {
                            log.error("image representation error.")
                        }
                    } else {
                        log.error("failed taking snapshot. error: \(String(describing: error?.localizedDescription))")
                    }
                    // レンダリング終了通知
                    self.endRendering(context: webView.context)
                }
            }
        }
    }

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

    /// フォーム情報取得
    func takeForm(webView: EGWebView) -> Form? {
        return webViewService.takeForm(webView: webView)
    }

    /// タブの追加
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

    /// フォーム情報保存
    func storeForm(form: Form) {
        FormUseCase.s.store(form: form)
    }

    func moveHistoryIfHistorySwipe(touchPoint: CGPoint) -> Bool {
        let isHistorySwipe = touchPoint.y < (AppConst.DEVICE.DISPLAY_SIZE.height / 2) - AppConst.BASE_LAYER.HEADER_HEIGHT

        if isHistorySwipe {
            state.remove(.isTouching)

            // 画面上半分のスワイプの場合は、履歴移動
            if swipeDirection == .left {
                historyBack()
            } else {
                historyForward()
            }
        }

        return isHistorySwipe
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

    /// 複合化
    func decrypt(value: Data) -> String {
        return EncryptService.decrypt(data: value)
    }
}
