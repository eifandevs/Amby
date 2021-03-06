//
//  BaseModels.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifandevs. All rights reserved.
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
    case append(currentTab: Tab)
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

    /// usecase
    let getSettingUseCase = GetSettingUseCase()

    var currentUrl: String? {
        return TabHandlerUseCase.s.currentUrl
    }

    var currentSession: Session? {
        return TabHandlerUseCase.s.currentSession
    }

    /// 現在のコンテキスト
    var currentContext: String? {
        return TabHandlerUseCase.s.currentContext
    }

    /// 現在の位置
    var currentLocation: Int? {
        return TabHandlerUseCase.s.currentLocation
    }

    /// webviewの数
    var currentTabCount: Int {
        return TabHandlerUseCase.s.currentTabCount
    }

    /// 自動スクロールのタイムインターバル
    var autoScrollInterval: CGFloat {
        return ScrollHandlerUseCase.s.autoScrollInterval
    }

    /// 新規ウィンドウ許諾
    var newWindowConfirm: Bool {
        return getSettingUseCase.newWindowConfirm
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
        return getWebConfigUseCase.exe()
    }

    /// ユースケース
    private let addTabUseCase = AddTabUseCase()
    private let insertHistoryUseCase = InsertHistoryUseCase()
    private let updateProgressUseCase = UpdateProgressUseCase()
    private let reloadProgressUseCase = ReloadProgressUseCase()
    private let updateTextProgressUseCase = UpdateTextProgressUseCase()
    private let insertTabUseCase = InsertTabUseCase()
    private let getIndexTabUseCase = GetIndexTabUseCase()
    private let startLoadingTabUseCase = StartLoadingTabUseCase()
    private let endLoadingTabUseCase = EndLoadingTabUseCase()
    private let endRenderingTabUseCase = EndRenderingTabUseCase()
    private let getHistoryTabUseCase = GetHistoryTabUseCase()
    private let goBackTabUseCase = GoBackTabUseCase()
    private let goNextTabUseCase = GoNextTabUseCase()
    private let updateUrlTabUseCase = UpdateUrlTabUseCase()
    private let updateTitleTabUseCase = UpdateTitleTabUseCase()
    private let updateSessionTabUseCase = UpdateSessionTabUseCase()
    private let getCaptureUseCase = GetCaptureUseCase()
    private let createThumbnailFolderUseCase = CreateThumbnailFolderUseCase()
    private let writeThumbnailUseCase = WriteThumbnailUseCase()
    private let deleteThumbnailUseCase = DeleteThumbnailUseCase()
    private let getWebConfigUseCase = GetWebCacheConfigUseCase()

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
            TrendHandlerUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            SourceCodeHandlerUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            ReportHandlerUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            FavoriteHanderUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            HistoryHandlerUseCase.s.rx_action
                .flatMap { action -> Observable<String> in
                    if case let .load(url) = action {
                        return Observable.just(url)
                    } else {
                        return Observable.empty()
                    }
                },
            SearchHandlerUseCase.s.rx_action
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
        TabHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .historyBack: self.rx_action.onNext(.historyBack)
                case .historyForward: self.rx_action.onNext(.historyForward)
                case let .insert(before, _): self.rx_action.onNext(.insert(at: before.index + 1))
                case .rebuild: self.rx_action.onNext(.rebuild)
                case .reload: self.rx_action.onNext(.reload)
                case let .append(_, after): self.rx_action.onNext(.append(currentTab: after.tab))
                case .change: self.rx_action.onNext(.change)
                case let .swap(start, end): self.rx_action.onNext(.swap(start: start, end: end))
                case let .delete(isFront, deleteContext, currentContext, deleteIndex): self.rx_action.onNext(.remove(isFront: isFront, deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex))
                default: break
                }
            }
            .disposed(by: disposeBag)

        // フォーム監視
        FormHandlerUseCase.s.rx_action
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
        ScrollHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .autoScroll: self.rx_action.onNext(.autoScroll)
                case .scrollUp: self.rx_action.onNext(.scrollUp)
                }
            }
            .disposed(by: disposeBag)

        // 全文検索監視
        GrepHandlerUseCase.s.rx_action
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
        HtmlAnalysisHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .analytics: self.rx_action.onNext(.analysisHtml)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: Public Method

    /// ページ追加
    func addTab() {
        addTabUseCase.exe()
    }

    /// html解析要求のurlか判定
    func isAnalysisUrl(url: String) -> Bool {
        return url.hasPrefix(AppConst.URL.ANALYSIS_URL_PREFIX)
    }

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

    /// KVO処理
    func observeValue(context: String, frontContext: String, isRestoreSessionUrl: Bool, keyPath: String?, change: [NSKeyValueChangeKey: Any]?) {
        if keyPath == "estimatedProgress" || keyPath == "title" || keyPath == "URL", isRestoreSessionUrl {
            log.warning("observe restore request. key: \(keyPath ?? "nokey")")
            return
        }

        if keyPath == "estimatedProgress" && context == frontContext {
            if let change = change, let progress = change[NSKeyValueChangeKey.newKey] as? CGFloat {
                // estimatedProgressが変更されたときに、プログレスバーの値を変更する。
                updateProgress(progress: progress)
            }
        } else if keyPath == "title" {
            log.debug("receive title change.")
            if let change = change, let title = change[NSKeyValueChangeKey.newKey] as? String {
                updatePageTitle(context: context, title: title)
            }
        } else if keyPath == "URL" {
            log.debug("receive url change.")
            if let change = change, let url = change[NSKeyValueChangeKey.newKey] as? URL, !url.absoluteString.isEmpty {
                updatePageUrl(context: context, url: url.absoluteString)
            }
        } else if keyPath == "canGoBack" {
            log.debug("receive canGoBack change.")
            if let change = change, let canGoBack = change[NSKeyValueChangeKey.newKey] as? Bool {
                updateCanGoBack(context: context, canGoBack: canGoBack)
            }
        } else if keyPath == "canGoForward" {
            log.debug("receive canGoFoward change.")
            if let change = change, let canGoFoward = change[NSKeyValueChangeKey.newKey] as? Bool {
                updateCanGoForward(context: context, canGoForward: canGoFoward)
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

    /// タブの追加
    func insertTab(url: String? = nil) {
        insertTabUseCase.exe(url: url)
    }

    /// ページインデックス取得
    func getTabIndex(context: String) -> Int? {
        return getIndexTabUseCase.exe(context: context)
    }

    func endGrepping(hitNum: Int) {
        GrepHandlerUseCase.s.finish(hitNum: hitNum)
    }

    func startLoading(context: String) {
        startLoadingTabUseCase.exe(context: context)
    }

    func endLoading(context: String) {
        endLoadingTabUseCase.exe(context: context)
    }

    func endRendering(context: String) {
        endRenderingTabUseCase.exe(context: context)
    }

    func updateProgress(progress: CGFloat) {
        updateProgressUseCase.exe(progress: progress)
    }

    /// 検索開始
    func beginSearching() {
        SearchHandlerUseCase.s.beginAtHeader()
    }

    /// フォーム情報保存
    func storeForm(form: Form) {
        StoreFormUseCase().exe(form: form)
    }

    /// フォーム情報取得
    func selectForm(url: String) -> Form? {
        return SelectFormUseCase().exe(url: url).first
    }

    /// 前webviewのキャプチャ取得
    func getPreviousCapture() -> UIImage? {
        if let currentLocation = currentLocation {
            let targetIndex = currentLocation == 0 ? currentTabCount - 1 : currentLocation - 1
            if let targetContext = getHistoryTabUseCase.exe(index: targetIndex)?.context {
                if let image = getCaptureUseCase.exe(context: targetContext) {
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
            if let targetContext = getHistoryTabUseCase.exe(index: targetIndex)?.context {
                if let image = getCaptureUseCase.exe(context: targetContext) {
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
        reloadProgressUseCase.exe()
    }

    /// update text in ProgressDataModel
    func updateProgressText(text: String) {
        updateTextProgressUseCase.exe(text: text)
    }

    /// 前WebViewに切り替え
    func goBackTab() {
        goBackTabUseCase.exe()
    }

    /// 後WebViewに切り替え
    func goNextTab() {
        goNextTabUseCase.exe()
    }

    /// create thumbnail folder
    func createThumbnailFolder(context: String) {
        createThumbnailFolderUseCase.exe(context: context)
    }

    /// write thumbnail data
    func writeThumbnailData(context: String, data: Data) {
        writeThumbnailUseCase.exe(context: context, data: data)
    }

    /// update url in page history
    func updatePageUrl(context: String, url: String) {
        updateUrlTabUseCase.exe(context: context, url: url)
    }

    /// update title in page history
    func updatePageTitle(context: String, title: String) {
        updateTitleTabUseCase.exe(context: context, title: title)
    }

    /// update canGoBack
    func updateCanGoBack(context: String, canGoBack: Bool) {
        ProgressHandlerUseCase.s.updateCanGoBack(context: context, canGoBack: canGoBack)
    }

    /// update canGoForward
    func updateCanGoForward(context: String, canGoForward: Bool) {
        ProgressHandlerUseCase.s.updateCanGoForward(context: context, canGoForward: canGoForward)
    }

    /// update session
    func updateSession(context: String, urls: [String], currentPage: Int) {
        updateSessionTabUseCase.exe(context: context, urls: urls, currentPage: currentPage)
    }

    /// update common history
    func insertHistory(url: URL?, title: String?) {
        insertHistoryUseCase.exe(url: url, title: title)
    }

    /// サムネイルの削除
    func deleteThumbnail(context: String) {
        deleteThumbnailUseCase.exe(context: context)
    }

    /// 複合化
    func decrypt(value: Data) -> String {
        return EncryptService.decrypt(data: value)
    }
}
