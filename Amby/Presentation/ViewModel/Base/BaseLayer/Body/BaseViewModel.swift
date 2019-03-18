//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Entity
import Foundation
import Model
import RxCocoa
import RxSwift

enum BaseViewModelAction {
    case insert(at: Int)
    case reload
    case rebuild
    case append
    case change
    case remove(isFront: Bool, deleteContext: String, currentContext: String?, deleteIndex: Int)
    case swap(start: Int, end: Int)
    case historyBack
    case historyForward
    case load(url: String)
    case form
    case autoScroll
    case autoFill
    case scrollUp
    case grep(text: String)
    case grepPrevious(index: Int)
    case grepNext(index: Int)
    case analysisHtml
}

struct BaseViewModelState: OptionSet {
    let rawValue: Int
    /// タッチ中フラグ
    static let isTouching = BaseViewModelState(rawValue: 1 << 0)
    /// アニメーション中フラグ
    static let isAnimating = BaseViewModelState(rawValue: 1 << 1)
    /// 自動入力ダイアログ表示済みフラグ
    static let isDoneAutoFill = BaseViewModelState(rawValue: 1 << 2)
    /// スクロール中フラグ
    static let isScrolling = BaseViewModelState(rawValue: 1 << 3)
    /// スワイプでページ切り替えを検知したかどうかのフラグ
    static let isChangingFront = BaseViewModelState(rawValue: 1 << 4)
    /// 新規タブイベント選択中
    static let isSelectingNewTabEvent = BaseViewModelState(rawValue: 1 << 5)
}

final class BaseViewModel {
    var state: BaseViewModelState = []

    let rx_action = PublishSubject<BaseViewModelAction>()

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

    /// webview configuration
    var cacheConfiguration: WKWebViewConfiguration {
        return WebCacheUseCase.s.cacheConfiguration()
    }

    /// Observable自動解放
    let disposeBag = DisposeBag()

    init() {
        setupRx()
    }

    deinit {
        log.debug("deinit called.")
    }

    func setupRx() {
        // ロード要求監視
        Observable.merge([
            TrendUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            SourceCodeUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            ReportUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            FavoriteUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            HistoryUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            SearchUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(text) = action {
                        return Observable.just(text)
                    } else {
                        return Observable.empty()
                    }
                }
        ]).subscribe { [weak self] url in
            guard let `self` = self, let url = url.element else { return }
            self.rx_action.onNext(.load(url: url))
        }
        .disposed(by: disposeBag)

        // タブ監視
        TabUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .historyBack: self.rx_action.onNext(.historyBack)
                case .historyForward: self.rx_action.onNext(.historyForward)
                case let .insert(before, _): self.rx_action.onNext(.insert(at: before.index + 1))
                case .rebuild: self.rx_action.onNext(.rebuild)
                case .reload: self.rx_action.onNext(.reload)
                case .append: self.rx_action.onNext(.append)
                case .change: self.rx_action.onNext(.change)
                case let .swap(start, end): self.rx_action.onNext(.swap(start: start, end: end))
                case let .delete(isFront, deleteContext, currentContext, deleteIndex): self.rx_action.onNext(.remove(isFront: isFront, deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex))
                default: break
                }
            }
            .disposed(by: disposeBag)

        // フォーム監視
        FormUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .register: self.rx_action.onNext(.form)
                case .autoFill: self.rx_action.onNext(.autoFill)
                default: break
                }
            }
            .disposed(by: disposeBag)

        // スクロール監視
        ScrollUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .autoScroll: self.rx_action.onNext(.autoScroll)
                case .scrollUp: self.rx_action.onNext(.scrollUp)
                }
            }
            .disposed(by: disposeBag)

        // 全文検索監視
        GrepUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .request(word): self.rx_action.onNext(.grep(text: word))
                case let .previous(index): self.rx_action.onNext(.grepPrevious(index: index))
                case let .next(index): self.rx_action.onNext(.grepNext(index: index))
                default: break
                }
            }
            .disposed(by: disposeBag)

        // html解析監視
        HtmlAnalysisUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .analytics: self.rx_action.onNext(.analysisHtml)
                default: break
                }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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

    /// html解析画面表示
    func presentHtmlAnalysis(html: String) {
        HtmlAnalysisUseCase.s.present(html: html)
    }

    /// タブの追加
    func insertTab(url: String? = nil) {
        TabUseCase.s.insert(url: url)
    }

    /// ページインデックス取得
    func getTabIndex(context: String) -> Int? {
        return TabUseCase.s.getIndex(context: context)
    }

    func endGrepping(hitNum: Int) {
        GrepUseCase.s.finish(hitNum: hitNum)
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

    /// フォーム情報取得
    func selectForm(url: String) -> Form? {
        return FormUseCase.s.select(url: url).first
    }

    func moveHistoryIfHistorySwipe(touchPoint _: CGPoint) -> Bool {
        return false
        // ヒストリースワイプはやめる
//        let isHistorySwipe = touchPoint.y < (AppConst.DEVICE.DISPLAY_SIZE.height / 2) - AppConst.BASE_LAYER.HEADER_HEIGHT
//
//        if isHistorySwipe {
//            state.remove(.isTouching)
//
//            // 画面上半分のスワイプの場合は、履歴移動
//            if swipeDirection == .left {
//                historyBack()
//            } else {
//                historyForward()
//            }
//        }
//
//        return isHistorySwipe
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

    /// create thumbnail folder
    func createThumbnailFolder(context: String) {
        ThumbnailUseCase.s.createFolder(context: context)
    }

    /// write thumbnail data
    func writeThumbnailData(context: String, data: Data) {
        ThumbnailUseCase.s.write(context: context, data: data)
    }

    /// update url in page history
    func updatePageUrl(context: String, url: String) {
        TabUseCase.s.updateUrl(context: context, url: url)
    }

    /// update title in page history
    func updatePageTitle(context: String, title: String) {
        TabUseCase.s.updateTitle(context: context, title: title)
    }

    /// update canGoBack
    func updateCanGoBack(context: String, canGoBack: Bool) {
        ProgressUseCase.s.updateCanGoBack(context: context, canGoBack: canGoBack)
    }

    /// update canGoForward
    func updateCanGoForward(context: String, canGoForward: Bool) {
        ProgressUseCase.s.updateCanGoForward(context: context, canGoForward: canGoForward)
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
