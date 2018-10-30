//
//  BaseViewControllerViewModel.swift
//  Eiger
//
//  Created by temma on 2017/02/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit
import WebKit

enum EdgeSwipeDirection: CGFloat {
    case right = 1
    case left = -1
    case none = 0
}

class BaseView: UIView {
    /// フロント変更通知用RX
    let rx_baseViewDidChangeFront = PublishSubject<()>()
    /// スライド通知用RX
    let rx_baseViewDidSlide = PublishSubject<CGFloat>()
    /// Maxスライド通知用RX
    let rx_baseViewDidSlideToMax = PublishSubject<()>()
    /// Minスライド通知用RX
    let rx_baseViewDidSlideToMin = PublishSubject<()>()
    /// ページスワイプ通知用RX
    let rx_baseViewDidEdgeSwiped = PublishSubject<EdgeSwipeDirection>()

    /// 編集状態にするクロージャ
    private var beginSearchingWorkItem: DispatchWorkItem?

    /// yポジションの最大最小値
    private let positionY: (max: CGFloat, min: CGFloat) = (AppConst.BASE_LAYER.HEADER_HEIGHT, AppConst.DEVICE.STATUS_BAR_HEIGHT)

    /// 最前面のWebView
    private var front: EGWebView! {
        willSet {
            if front != nil {
                // 高さの初期化
                front.frame.size.height = frame.size.height
            }
        }
        didSet {
            if front != nil {
                // 高さの初期化
                front.frame.size.height = frame.size.height
                // 移動量の初期化
                scrollMovingPointY = 0
                // プライベートモードならデザインを変更する
                rx_baseViewDidChangeFront.onNext(())
                // ヘッダーフィールドを更新する
                viewModel.reloadProgress()
                // 空ページの場合は、編集状態にする
                if viewModel.currentUrl.isEmpty {
                    if let beginSearchingWorkItem = self.beginSearchingWorkItem {
                        beginSearchingWorkItem.cancel()
                    }
                    beginSearchingWorkItem = DispatchWorkItem { [weak self] in
                        guard let `self` = self else { return }
                        self.viewModel.beginSearching()
                        self.beginSearchingWorkItem = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: beginSearchingWorkItem!)
                }
            }
        }
    }

    /// 現在表示中の全てのWebView。アプリを殺して、起動した後などは、WebViewインスタンスは入っていないが、配列のスペースは作成される
    private var webViews: [EGWebView?] = []
    /// 前後ページ
    private let previousImageView: UIImageView = UIImageView()
    private let nextImageView: UIImageView = UIImageView()
    /// ビューモデル
    private let viewModel = BaseViewModel()
    /// Y軸移動量を計算するための一時変数
    private var scrollMovingPointY: CGFloat = 0
    /// 自動入力ダイアログ表示済みフラグ
    private var isDoneAutoFill = false
    /// タッチ中フラグ
    private var isTouching = false
    /// アニメーション中フラグ
    private var isAnimating = false
    /// 自動スクロール
    private var autoScrollTimer: Timer?
    /// スワイプ方向
    private var swipeDirection: EdgeSwipeDirection = .none
    /// タッチ開始位置
    private var touchBeganPoint: CGPoint?
    /// スワイプでページ切り替えを検知したかどうかのフラグ
    private var isChangingFront: Bool = false
    /// 新規タブイベント選択中
    private var isSelectingNewTabEvent = false
    /// スライド中かどうかのフラグ
    var isMoving: Bool {
        return !isLocateMax && !isLocateMin
    }

    /// スクロール中フラグ
    var isScrolling: Bool = false

    /// ベースビューがMaxポジションにあるかどうかのフラグ
    var isLocateMax: Bool {
        return frame.origin.y == positionY.max
    }

    /// ベースビューがMinポジションにあるかどうかのフラグ
    var isLocateMin: Bool {
        return frame.origin.y == positionY.min
    }

    /// 逆順方向のスクロールが可能かどうかのフラグ
    var canPastScroll: Bool {
        return front.scrollView.contentOffset.y > 0
    }

    /// 順方向のスクロールが可能かどうかのフラグ
    var canForwardScroll: Bool {
        return front.scrollView.contentOffset.y < front.scrollView.contentSize.height - front.frame.size.height
    }

    /// スクロールすべきかどうかのフラグ
    var shouldScroll: Bool {
        return front.scrollView.contentSize.height > AppConst.BASE_LAYER.BASE_HEIGHT
    }

    /// Observable自動解放
    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        EGApplication.sharedMyApplication.egDelegate = self

        // webviewsに初期値を入れる
        (0 ... viewModel.currentTabCount - 1).forEach { _ in
            webViews.append(nil)
        }

        let newWv = createWebView(size: frame.size, context: viewModel.currentContext)
        if let currentLocation = viewModel.currentLocation {
            webViews[currentLocation] = newWv
        } else {
            log.error("cannot get currentLocation.")
        }

        // 前後のページ
        previousImageView.frame = CGRect(origin: CGPoint(x: -frame.size.width, y: 0), size: frame.size)
        nextImageView.frame = CGRect(origin: CGPoint(x: frame.size.width, y: 0), size: frame.size)
        addSubview(previousImageView)
        addSubview(nextImageView)

        // ロードする
        if !viewModel.currentUrl.isEmpty {
            if let url = viewModel.currentUrl {
                _ = newWv.load(urlStr: url)
            } else {
                log.error("cannot get currentUrl.")
            }
        } else {
            // 1秒後にwillbeginSearchingする
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.beginSearching()
            }
        }

        setupRx()
    }

    private func setupRx() {
        // ページインサート監視
        viewModel.rx_baseViewModelDidInsertWebView
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidInsertWebView")
                guard let `self` = self else { return }
                if let at = object.element {
                    // 現フロントのプログレス監視を削除
                    if let front = self.front {
                        front.removeObserverEstimatedProgress(observer: self)
                    }
                    self.viewModel.updateProgress(progress: 0)
                    let newWv = self.createWebView(context: self.viewModel.currentContext)
                    self.webViews.insert(newWv, at: at)
                    if self.viewModel.currentUrl.isEmpty {
                        // 編集状態にする
                        if let beginSearchingWorkItem = self.beginSearchingWorkItem {
                            beginSearchingWorkItem.cancel()
                        }
                        self.beginSearchingWorkItem = DispatchWorkItem { [weak self] in
                            guard let `self` = self else { return }
                            self.viewModel.beginSearching()
                            self.beginSearchingWorkItem = nil
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: self.beginSearchingWorkItem!)
                    } else {
                        if let url = self.viewModel.currentUrl {
                            _ = newWv.load(urlStr: url)
                        } else {
                            log.error("cannot get currentUrl.")
                        }
                    }
                }
                log.eventOut(chain: "rx_baseViewModelDidInsertWebView")
            }
            .disposed(by: disposeBag)

        // 自動入力監視
        viewModel.rx_baseViewModelDidAutoFill
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidAutoFill")
                guard let `self` = self else { return }
                if !self.isDoneAutoFill {
                    if let url = self.front.url?.absoluteString, let inputForm = FormUseCase.s.select(url: url).first {
                        NotificationManager.presentAlert(title: MessageConst.ALERT.FORM_TITLE, message: MessageConst.ALERT.FORM_EXIST, completion: { [weak self] in
                            guard let `self` = self else { return }
                            inputForm.inputs.forEach {
                                let value = self.viewModel.decrypt(value: $0.value)
                                let input = $0
                                // set form
                                DispatchQueue.mainSyncSafe {
                                    self.front.evaluateJavaScript("document.forms[\(input.formIndex)].elements[\(input.formInputIndex)].value='\(value)'") { (_: Any?, error: Error?) in
                                        if error != nil {
                                            log.error("set form error: \(error!)")
                                        }
                                    }
                                }
                            }
                        })
                        self.isDoneAutoFill = true
                    }
                }
                log.eventOut(chain: "rx_baseViewModelDidAutoFill")
            }
            .disposed(by: disposeBag)

        // ページ追加監視
        viewModel.rx_baseViewModelDidAppendWebView
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidAppendWebView")
                guard let `self` = self else { return }
                // 現フロントのプログレス監視を削除
                if let front = self.front {
                    front.removeObserverEstimatedProgress(observer: self)
                }
                self.viewModel.updateProgress(progress: 0)
                let newWv = self.createWebView(context: self.viewModel.currentContext)
                self.webViews.append(newWv)
                if self.viewModel.currentUrl.isEmpty {
                    // 編集状態にする
                    if let beginSearchingWorkItem = self.beginSearchingWorkItem {
                        beginSearchingWorkItem.cancel()
                    }
                    self.beginSearchingWorkItem = DispatchWorkItem { [weak self] in
                        guard let `self` = self else { return }
                        self.viewModel.beginSearching()
                        self.beginSearchingWorkItem = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: self.beginSearchingWorkItem!)
                } else {
                    if let url = self.viewModel.currentUrl {
                        _ = newWv.load(urlStr: url)
                    } else {
                        log.error("cannot get currentUrl.")
                    }
                }
                log.eventOut(chain: "rx_baseViewModelDidAppendWebView")
            }
            .disposed(by: disposeBag)

        // リロード監視
        viewModel.rx_baseViewModelDidReloadWebView
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidReloadWebView")
                guard let `self` = self else { return }
                if self.front.isValidUrl {
                    self.front.reload()
                } else {
                    if let url = self.viewModel.currentUrl {
                        _ = self.front.load(urlStr: url)
                    }
                }
                log.eventOut(chain: "rx_baseViewModelDidReloadWebView")
            }
            .disposed(by: disposeBag)

        // ページ変更監視
        viewModel.rx_baseViewModelDidChangeWebView
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidChangeWebView")
                guard let `self` = self else { return }
                if let currentLocation = self.viewModel.currentLocation {
                    self.front.removeObserverEstimatedProgress(observer: self)
                    self.viewModel.updateProgress(progress: 0)

                    if let current = self.webViews[currentLocation] {
                        current.observeEstimatedProgress(observer: self)
                        if current.isLoading == true {
                            self.viewModel.updateProgress(progress: CGFloat(current.estimatedProgress))
                        }
                        self.front = current
                        self.bringSubview(toFront: current)
                    } else {
                        self.loadWebView()
                    }
                } else {
                    log.error("cannot find current location.")
                }

                log.eventOut(chain: "rx_baseViewModelDidChangeWebView")
            }
            .disposed(by: disposeBag)

        // ページ削除監視
        viewModel.rx_baseViewModelDidRemoveWebView
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidRemoveWebView")
                guard let `self` = self else { return }
                if let object = object.element {
                    if let webView = self.webViews[object.deleteIndex] {
                        let isFrontDelete = object.deleteContext == self.front.context
                        if isFrontDelete {
                            webView.removeObserverEstimatedProgress(observer: self)
                            self.viewModel.updateProgress(progress: 0)
                            self.front = nil
                        }

                        // ローディングキャンセル
                        if webView.isLoading {
                            webView.stopLoading()
                        }

                        webView.removeFromSuperview()
                        self.webViews.remove(at: object.deleteIndex)

                        // くるくるを更新
                        self.updateNetworkActivityIndicator()

                        if isFrontDelete && object.currentContext != nil {
                            // フロントの削除で、削除後にwebviewが存在する場合
                            if let current = self.webViews.find({ $0?.context == TabUseCase.s.currentContext })! {
                                current.observeEstimatedProgress(observer: self)
                                self.front = current
                                self.bringSubview(toFront: current)
                            } else {
                                self.loadWebView()
                            }
                        }
                    }
                }
                log.eventOut(chain: "rx_baseViewModelDidRemoveWebView")
            }
            .disposed(by: disposeBag)

        // 検索監視
        viewModel.rx_baseViewModelDidSearchWebView
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidSearchWebView")
                guard let `self` = self else { return }
                if let text = object.element {
                    _ = self.front.load(urlStr: text)
                }
                log.eventOut(chain: "rx_baseViewModelDidSearchWebView")
            }
            .disposed(by: disposeBag)

        // トレンド表示監視
        viewModel.rx_baseViewModelDidLoadTrend
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidLoadTrend")
                guard let `self` = self else { return }
                if let url = object.element {
                    _ = self.front.load(urlStr: url)
                }
                log.eventOut(chain: "rx_baseViewModelDidLoadTrend")
            }
            .disposed(by: disposeBag)

        // ソースコード表示監視
        viewModel.rx_baseViewModelDidLoadSourceCode
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidLoadSourceCode")
                guard let `self` = self else { return }
                if let url = object.element {
                    _ = self.front.load(urlStr: url)
                }
                log.eventOut(chain: "rx_baseViewModelDidLoadSourceCode")
            }
            .disposed(by: disposeBag)

        // Issue表示監視
        viewModel.rx_baseViewModelDidLoadIssue
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidLoadIssue")
                guard let `self` = self else { return }
                if let url = object.element {
                    _ = self.front.load(urlStr: url)
                }
                log.eventOut(chain: "rx_baseViewModelDidLoadIssue")
            }
            .disposed(by: disposeBag)

        // ロードリクエスト監視(favorite)
        viewModel.rx_baseViewModelDidLoadFavorite
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidLoadFavorite")
                guard let `self` = self else { return }
                if let url = object.element {
                    _ = self.front.load(urlStr: url)
                }
                log.eventOut(chain: "rx_baseViewModelDidLoadFavorite")
            }
            .disposed(by: disposeBag)

        // ロードリクエスト監視(form)
        viewModel.rx_baseViewModelDidLoadForm
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidLoadForm")
                guard let `self` = self else { return }
                if let url = object.element {
                    _ = self.front.load(urlStr: url)
                }
                log.eventOut(chain: "rx_baseViewModelDidLoadForm")
            }
            .disposed(by: disposeBag)

        // ロードリクエスト監視(form)
        viewModel.rx_baseViewModelDidLoadHistory
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidLoadHistory")
                guard let `self` = self else { return }
                if let url = object.element {
                    _ = self.front.load(urlStr: url)
                }
                log.eventOut(chain: "rx_baseViewModelDidLoadHistory")
            }
            .disposed(by: disposeBag)

        // observe history back
        viewModel.rx_baseViewModelDidHistoryBackWebView
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidHistoryBackWebView")
                guard let `self` = self else { return }
                if let isPastViewing = self.viewModel.getIsPastViewing(context: self.front.context) {
                    if self.front.isLoading && self.front.operation == .normal && !isPastViewing {
                        // 新規ページ表示中に戻るを押下したルート
                        log.debug("go back on loading.")

                        if let url = self.viewModel.getMostForwardUrl(context: self.front.context) {
                            self.front.operation = .back
                            _ = self.front.load(urlStr: url)
                        }
                    } else {
                        log.debug("go back.")
                        // 有効なURLを探す
                        if let url = self.viewModel.getBackUrl(context: self.front.context) {
                            self.front.operation = .back
                            _ = self.front.load(urlStr: url)
                        }
                    }
                }
                log.eventOut(chain: "rx_baseViewModelDidHistoryBackWebView")
            }
            .disposed(by: disposeBag)

        // ヒストリーフォワード監視
        viewModel.rx_baseViewModelDidHistoryForwardWebView
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidHistoryForwardWebView")
                guard let `self` = self else { return }
                if let url = self.viewModel.getForwardUrl(context: self.front.context) {
                    self.front.operation = .forward
                    _ = self.front.load(urlStr: url)
                }
                log.eventOut(chain: "rx_baseViewModelDidHistoryForwardWebView")
            }.disposed(by: disposeBag)

        // フォーム登録監視
        viewModel.rx_baseViewModelDidRegisterAsForm
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidRegisterAsForm")
                guard let `self` = self else { return }
                if let form = self.takeForm(webView: self.front) {
                    self.viewModel.storeForm(form: form)
                } else {
                    NotificationManager.presentToastNotification(message: MessageConst.NOTIFICATION.REGISTER_FORM_ERROR_CRAWL, isSuccess: false)
                }
                log.eventOut(chain: "rx_baseViewModelDidRegisterAsForm")
            }
            .disposed(by: disposeBag)

        // 自動スクロール監視
        viewModel.rx_baseViewModelDidAutoScroll
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidAutoScroll")
                guard let `self` = self else { return }
                if self.autoScrollTimer != nil || self.autoScrollTimer?.isValid == true {
                    self.autoScrollTimer?.invalidate()
                    self.autoScrollTimer = nil
                } else {
                    self.autoScrollTimer = Timer.scheduledTimer(timeInterval: Double(self.viewModel.autoScrollInterval), target: self, selector: #selector(self.updateAutoScrolling), userInfo: nil, repeats: true)
                    self.autoScrollTimer?.fire()
                }
                log.eventOut(chain: "rx_baseViewModelDidAutoScroll")
            }
            .disposed(by: disposeBag)

        // observe scroll up
        viewModel.rx_baseViewModelDidScrollUp
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_baseViewModelDidScrollUp")
                guard let `self` = self else { return }
                // スクロールアップ
                DispatchQueue.mainSyncSafe {
                    self.front.evaluateJavaScript("window.scrollTo(0, 0)") { _, _ in
                    }
                }
                log.eventOut(chain: "rx_baseViewModelDidScrollUp")
            }
            .disposed(by: disposeBag)

        // 全文検索監視
        viewModel.rx_baseViewModelDidGrep
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewModelDidGrep")
                guard let `self` = self else { return }
                if let searchText = object.element {
                    self.front.highlight(word: searchText)
                }
                log.eventOut(chain: "rx_baseViewModelDidGrep")
            }
            .disposed(by: disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        webViews.forEach { webView in
            if let unwrappedWebView = webView {
                unwrappedWebView.removeObserverEstimatedProgress(observer: self)
                unwrappedWebView.removeObserverTitle(observer: self)
                unwrappedWebView.removeObserverUrl(observer: self)
            }
        }
        NotificationCenter.default.removeObserver(self)
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: KVO(Progress)

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context pointer: UnsafeMutableRawPointer?) {
        let opaquePtr = OpaquePointer(pointer)
        if let contextPtr = UnsafeMutablePointer<String>(opaquePtr) {
            if keyPath == "estimatedProgress" && contextPtr.pointee == front.context {
                if let change = change, let progress = change[NSKeyValueChangeKey.newKey] as? CGFloat {
                    // estimatedProgressが変更されたときに、プログレスバーの値を変更する。
                    viewModel.updateProgress(progress: progress)
                }
            } else if keyPath == "title" {
                log.debug("receive title change.")
                if let change = change, let title = change[NSKeyValueChangeKey.newKey] as? String {
                    viewModel.updatePageTitle(context: contextPtr.pointee, title: title)
                }
            } else if keyPath == "URL" {
                log.debug("receive url change.")
                if let change = change, let url = change[NSKeyValueChangeKey.newKey] as? URL, !url.absoluteString.isEmpty {
                    if let targetWebView = self.webViews.find({ $0?.context == contextPtr.pointee })! {
                        viewModel.updatePageUrl(context: contextPtr.pointee, url: url.absoluteString, operation: targetWebView.operation)
                        // 操作種別はnormalに戻しておく
                        // ヒストリーバック or ヒストリーフォワードで遷移したときは、リダイレクトを除きタップから連続してのURL変更がないはず
                        if targetWebView.operation != .normal {
                            targetWebView.operation = .normal
                        }
                    }
                }
            }
        }
    }

    // MARK: Public Method

    func getFrontUrl() -> String? {
        return front.url?.absoluteString
    }

    private func slide(value: CGFloat) {
        rx_baseViewDidSlide.onNext(value)
        frame.origin.y += value
        front.frame.size.height -= value
        // スライドと同時にスクロールが発生しているので、逆方向にスクロールし、スクロールを無効化する
        front.scrollView.setContentOffset(CGPoint(x: front.scrollView.contentOffset.x, y: front.scrollView.contentOffset.y + value), animated: false)
    }

    /// サイズの最大化
    func scaleToMax() {
        frame.size.height = AppConst.BASE_LAYER.BASE_HEIGHT
        front.frame.size.height = AppConst.BASE_LAYER.BASE_HEIGHT
    }

    /// サイズの最小化
    func scaleToMin() {
        frame.size.height = AppConst.BASE_LAYER.BASE_HEIGHT - AppConst.BASE_LAYER.HEADER_HEIGHT + AppConst.DEVICE.STATUS_BAR_HEIGHT
        front.frame.size.height = AppConst.BASE_LAYER.BASE_HEIGHT - AppConst.BASE_LAYER.HEADER_HEIGHT + AppConst.DEVICE.STATUS_BAR_HEIGHT
    }

    /// 高さの最大位置までスライド
    func slideToMax() {
        if !isLocateMax {
            rx_baseViewDidSlideToMax.onNext(())
            frame.origin.y = AppConst.BASE_LAYER.HEADER_HEIGHT
            scaleToMin()
        }
    }

    /// 高さの最小位置までスライド
    func slideToMin() {
        if !isLocateMin {
            rx_baseViewDidSlideToMin.onNext(())
            frame.origin.y = AppConst.DEVICE.STATUS_BAR_HEIGHT
            scaleToMax()
        }
    }

    func validateUserInteraction() {
        isUserInteractionEnabled = true
        // グローバル画面タッチイベントを奪う
        EGApplication.sharedMyApplication.egDelegate = self
        webViews.forEach { (wv: EGWebView?) in
            if let wv = wv, !wv.scrollView.isScrollEnabled {
                wv.scrollView.isScrollEnabled = true
                wv.scrollView.bounces = true
            }
        }
    }

    // MARK: Private Method

    private func takeForm(webView: EGWebView) -> Form? {
        if let title = webView.title, let host = webView.url?.host, let url = webView.url?.absoluteString {
            let form = Form()
            form.title = title
            form.host = host
            form.url = url

            // take form
            webView.evaluate(script: "document.forms.length") { object, error in
                if object != nil && error == nil {
                    let formLength = Int(truncating: (object as? NSNumber)!)
                    if formLength > 0 {
                        for i in 0 ... (formLength - 1) {
                            webView.evaluate(script: "document.forms[\(i)].elements.length") { object, error in
                                if (object != nil) && (error == nil) {
                                    let elementLength = Int(truncating: (object as? NSNumber)!)
                                    for j in 0 ... elementLength {
                                        webView.evaluate(script: "document.forms[\(i)].elements[\(j)].type") { object, error in
                                            if (object != nil) && (error == nil) {
                                                let type = object as? String
                                                if (type != "hidden") && (type != "submit") && (type != "checkbox") {
                                                    let input = Input()
                                                    webView.evaluate(script: "document.forms[\(i)].elements[\(j)].value") { object, _ in
                                                        if let value = object as? String {
                                                            if value.count > 0 {
                                                                input.type = type!
                                                                input.formIndex = i
                                                                input.formInputIndex = j
                                                                input.value = self.viewModel.encrypt(value: value)
                                                                form.inputs.append(input)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return form
        }
        return nil
    }

    private func updateNetworkActivityIndicator() {
        let loadingWebViews: [EGWebView?] = webViews.filter({ (wv) -> Bool in
            if let wv = wv {
                return wv.isLoading
            }
            return false
        })
        // 他にローディング中のwebviewがなければ、くるくるを停止する
        UIApplication.shared.isNetworkActivityIndicatorVisible = loadingWebViews.count < 1 ? false : true
    }

    private func invalidateUserInteraction() {
        touchBeganPoint = nil
        isUserInteractionEnabled = false
        front.scrollView.isScrollEnabled = false
        front.scrollView.bounces = false
    }

    private func startObserving(target: EGWebView) {
        log.debug("start observe. target: \(target.context)")

        target.observeEstimatedProgress(observer: self)
        target.observeTitle(observer: self)
        target.observeUrl(observer: self)

        if target.isLoading == true {
            viewModel.updateProgress(progress: CGFloat(target.estimatedProgress))
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = target.isLoading
    }

    /// webviewを新規作成
    private func createWebView(size: CGSize? = nil, context: String?) -> EGWebView {
        let newWv = EGWebView(id: context)
        newWv.frame = CGRect(origin: CGPoint.zero, size: size ?? frame.size)
        // RXで自身をもらえず循環参照になるので、RX化しない
        newWv.navigationDelegate = self
        newWv.uiDelegate = self
        newWv.scrollView.delegate = self
        front = newWv
        viewModel.createThumbnailFolder(context: newWv.context)
        addSubview(newWv)

        // プログレスバー
        startObserving(target: newWv)

        return newWv
    }

    // loadWebViewはwebviewスペースがある状態で新規作成するときにコールする
    private func loadWebView() {
        let newWv = createWebView(context: viewModel.currentContext)
        webViews[viewModel.currentLocation!] = newWv
        if let url = viewModel.currentUrl, !url.isEmpty {
            newWv.load(urlStr: url)
        } else {
            log.error("cannot get currentUrl.")
        }
    }

    private func saveThumbnail(webView: EGWebView, completion: @escaping (() -> Void)) {
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
                            self.viewModel.writeThumbnailData(context: context, data: pngImageData)
                        } else {
                            log.error("image representation error.")
                        }
                        completion()
                    } else {
                        log.error("failed taking snapshot. error: \(String(describing: error?.localizedDescription))")
                        completion()
                    }
                }
            }
        }
    }

    // MARK: 自動スクロールタイマー通知

    @objc func updateAutoScrolling(sender: Timer) {
        if let front = front {
            let bottomOffset = front.scrollView.contentSize.height - front.scrollView.bounds.size.height + front.scrollView.contentInset.bottom
            if front.scrollView.contentOffset.y >= bottomOffset {
                sender.invalidate()
                autoScrollTimer = nil
                front.scrollView.scroll(to: .bottom, animated: false)
            } else {
                front.scrollView.setContentOffset(CGPoint(x: front.scrollView.contentOffset.x, y: front.scrollView.contentOffset.y + viewModel.autoScrollSpeed), animated: false)
            }
        }
    }
}

// MARK: EGApplication Delegate

extension BaseView: EGApplicationDelegate {
    internal func screenTouchBegan(touch: UITouch) {
        if !viewModel.canSwipe {
            log.warning("cannot swipe.")
            isTouching = false
            return
        }

        isTouching = true
        isChangingFront = false
        touchBeganPoint = touch.location(in: self)
        if touchBeganPoint!.x < AppConst.FRONT_LAYER.EDGE_SWIPE_EREA {
            swipeDirection = .left
        } else if touchBeganPoint!.x > bounds.size.width - AppConst.FRONT_LAYER.EDGE_SWIPE_EREA {
            swipeDirection = .right
        } else {
            swipeDirection = .none
        }
    }

    internal func screenTouchMoved(touch: UITouch) {
        if !isTouching { return }

        if let touchBeganPoint = touchBeganPoint, front.scrollView.isScrollEnabled {
            let touchPoint = touch.location(in: self)
            if (swipeDirection == .left && touchPoint.x > AppConst.FRONT_LAYER.EDGE_SWIPE_EREA + 20) ||
                (swipeDirection == .right && touchPoint.x < bounds.width - AppConst.FRONT_LAYER.EDGE_SWIPE_EREA - 20) {
                // エッジスワイプ検知
                // 動画DL
//                self.front.evaluateJavaScript("document.querySelector('video').currentSrc") { (object, error) in
//                    log.warning("object: \(object)")
//                }

                if viewModel.isHistorySwipe(touchPoint: touchBeganPoint) {
                    isTouching = false
                    // 画面上半分のスワイプの場合は、履歴移動
                    if swipeDirection == .left {
                        viewModel.historyBack()
                    } else {
                        viewModel.historyForward()
                    }
                } else {
                    // 操作を無効化
                    invalidateUserInteraction()

                    rx_baseViewDidEdgeSwiped.onNext(swipeDirection)
                }
            }

            if webViews.count > 1 && swipeDirection == .none && front.isSwiping {
                // フロントの左右に切り替え後のページを表示しとく
                if previousImageView.image == nil && nextImageView.image == nil {
                    previousImageView.image = viewModel.getPreviousCapture()
                    nextImageView.image = viewModel.getNextCapture()
                }
                if isChangingFront {
                    let previousTouchPoint = touch.previousLocation(in: self)
                    let distance: CGPoint = touchPoint - previousTouchPoint
                    frame.origin.x += distance.x
                } else {
                    if touchBeganPoint.y != -1 {
                        if fabs(touchPoint.y - touchBeganPoint.y) < 7.5 {
                            // エッジスワイプではないスワイプを検知し、y軸に誤差7.5pxで、x軸に11px移動したらフロントビューの移動をする
                            if fabs(touchPoint.x - touchBeganPoint.x) > 11 {
                                isChangingFront = true
                            }
                        } else {
                            self.touchBeganPoint!.y = -1
                        }
                    }
                }
            }
        }
    }

    internal func screenTouchEnded(touch _: UITouch) {
        if !isTouching { return }

        isTouching = false
        if isChangingFront {
            isChangingFront = false
            let targetOriginX = { () -> CGFloat in
                if frame.origin.x > frame.size.width / 3 {
                    return frame.size.width
                } else if frame.origin.x < -(frame.size.width / 3) {
                    return -frame.size.width
                } else {
                    return 0
                }
            }()
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.x = targetOriginX
            }, completion: { finished in
                if finished {
                    // 入れ替える
                    if targetOriginX == self.frame.size.width {
                        // 前のwebviewに遷移
                        self.viewModel.goBackTab()
                    } else if targetOriginX == -self.frame.size.width {
                        self.viewModel.goNextTab()
                    }
                    // baseViewの位置を元に戻す
                    self.frame.origin.x = 0
                    self.previousImageView.image = nil
                    self.nextImageView.image = nil
                }
            })
        }
    }

    internal func screenTouchCancelled(touch: UITouch) {
        screenTouchEnded(touch: touch)
    }
}

// MARK: ScrollView Delegate

extension BaseView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // フロントのみ通知する
        if let front = front, isScrolling {
            if front.scrollView == scrollView {
                if scrollMovingPointY != 0 {
                    let isOverScrolling = (scrollView.contentOffset.y <= 0) || (scrollView.contentOffset.y >= scrollView.contentSize.height - frame.size.height)
                    var speed = scrollView.contentOffset.y - scrollMovingPointY
                    if scrollMovingPointY != 0 && !isOverScrolling || (canForwardScroll && isOverScrolling && speed < 0) || (isOverScrolling && speed > 0 && scrollView.contentOffset.y > 0) {
                        speed = -speed
                        // スライド処理
                        if speed > 0 {
                            // ベースビューがスライド可能な場合にスライドさせる
                            if !isLocateMax {
                                if frame.origin.y + speed > positionY.max {
                                    // スライドした結果、Maxを超える場合は、調整する
                                    slideToMax()
                                } else {
                                    // コンテンツサイズが画面より小さい場合は、過去スクロールしない
                                    if speed >= 0 || shouldScroll {
                                        if !isAnimating {
                                            slide(value: speed)
                                        }
                                    }
                                }
                            }
                        } else if speed < 0 {
                            // 順方向(未来)のスクロール
                            // ベースビューがスライド可能な場合にスライドさせる
                            if !isLocateMin {
                                if frame.origin.y + speed < positionY.min {
                                    // スライドした結果、Minを下回る場合は、調整する
                                    slideToMin()
                                } else {
                                    // コンテンツサイズが画面より小さい場合は、過去スクロールしない
                                    if speed >= 0 || shouldScroll {
                                        if !isAnimating {
                                            slide(value: speed)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                scrollMovingPointY = scrollView.contentOffset.y
            }
        }
    }

    /// スクロールさせずに、その場で手を離した場合
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset _: UnsafeMutablePointer<CGPoint>) {
        // フロントのみ通知する
        if let front = front {
            if front.scrollView == scrollView {
                if velocity.y == 0 && !isTouching {
                    // タッチ終了時にベースビューの高さを調整する
                    if isScrolling && !isAnimating {
                        isScrolling = false
                        if isMoving {
                            isAnimating = true
                            if frame.origin.y > positionY.max / 2 {
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.slideToMax()
                                }, completion: { finished in
                                    if finished {
                                        self.isAnimating = false
                                    }
                                })
                            } else {
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.slideToMin()
                                }, completion: { finished in
                                    if finished {
                                        self.isAnimating = false
                                    }
                                })
                            }
                        }
                    }
                    scrollMovingPointY = 0
                }
            }
        }
    }

    /// 慣性スクロールをした場合
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // フロントのみ通知する
        if let front = front {
            if front.scrollView == scrollView {
                if !isTouching && !isAnimating {
                    // タッチ終了時にベースビューの高さを調整する
                    if isScrolling && !isAnimating {
                        isScrolling = false
                        if isMoving {
                            isAnimating = true
                            if frame.origin.y > positionY.max / 2 {
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.slideToMax()
                                }, completion: { finished in
                                    if finished {
                                        self.isAnimating = false
                                    }
                                })
                            } else {
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.slideToMin()
                                }, completion: { finished in
                                    if finished {
                                        self.isAnimating = false
                                    }
                                })
                            }
                        }
                    }
                    scrollMovingPointY = 0
                }
            }
        }
    }
}

// MARK: WKNavigationDelegate, UIWebViewDelegate, WKUIDelegate

extension BaseView: WKNavigationDelegate, UIWebViewDelegate, WKUIDelegate {
    /// force touchを無効にする
    func webView(_: WKWebView, shouldPreviewElement _: WKPreviewElementInfo) -> Bool {
        return false
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        guard let wv = webView as? EGWebView else { return }
        log.debug("loading start. context: \(wv.context)")

        if wv.context == front.context {
            // フロントwebviewの通知なので、プログレスを更新する
            // インジゲーターの表示、非表示をきりかえる。
            viewModel.startLoading(context: wv.context)
            viewModel.updateProgress(progress: CGFloat(0.1))
            // くるくるを更新する
            updateNetworkActivityIndicator()
        } else {
            // インジゲーターの表示、非表示をきりかえる。
            viewModel.startLoading(context: wv.context)
            // くるくるを更新する
            updateNetworkActivityIndicator()
        }
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        guard let wv = webView as? EGWebView else { return }
        log.debug("loading finish. context: \(wv.context)")

        // 削除済みチェック
        if viewModel.getTabIndex(context: wv.context) == nil {
            log.warning("loading finish on deleted page.")
            return
        }

        // store common history
        viewModel.insertHistory(url: wv.url, title: wv.title)

        // プログレス更新
        if wv.context == front.context {
            isDoneAutoFill = false
            viewModel.updateProgress(progress: 1.0)
        }
        updateNetworkActivityIndicator()
        viewModel.endLoading(context: wv.context)

        // サムネイルを保存
        saveThumbnail(webView: wv, completion: {
            // プログレス更新
            self.viewModel.endRendering(context: wv.context)
        })
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        log.error("[error url]\(String(describing: (error as NSError).userInfo["NSErrorFailingURLKey"])). code: \((error as NSError).code)")

        guard let wv = webView as? EGWebView else { return }

        // 連打したら-999 "(null)"になる対応
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }

        // プログレス更新
        DispatchQueue.mainSyncSafe {
            // プログレス更新
            if wv.context == front.context {
                viewModel.updateProgress(progress: 0)
            }
            self.updateNetworkActivityIndicator()
            self.viewModel.endLoading(context: wv.context)
        }

        // URLスキーム対応
        if let errorUrl = (error as NSError).userInfo["NSErrorFailingURLKey"] {
            if let url = (errorUrl as? NSURL)?.absoluteString {
                if !url.isValidUrl || url.range(of: AppConst.URL.ITUNES_STORE) != nil {
                    log.warning("load error. [open url event]")
                    return
                }
            }
        }

        wv.loadHtml(error: (error as NSError))
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let egWv: EGWebView = webView as? EGWebView else { return }

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            // SSL認証
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            // Basic認証
            let alertController = UIAlertController(title: "Authentication Required", message: webView.url!.host, preferredStyle: .alert)
            weak var usernameTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Username"
                usernameTextField = textField
            }
            weak var passwordTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                passwordTextField = textField
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(.cancelAuthenticationChallenge, nil)
                egWv.loadHtml(code: .unauthorized)
            }))
            alertController.addAction(UIAlertAction(title: "Log In", style: .default, handler: { _ in
                let credential = URLCredential(user: usernameTextField.text!, password: passwordTextField.text!, persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, credential)
            }))
            Util.foregroundViewController().present(alertController, animated: true, completion: nil)
        }
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        // 新規ウィンドウ選択中の場合はキャンセル
        if isSelectingNewTabEvent {
            log.debug("cancel url: \(url)")
            decisionHandler(.cancel)
            return
        }

        // 自動スクロールを停止する
        if let autoScrollTimer = autoScrollTimer, autoScrollTimer.isValid {
            autoScrollTimer.invalidate()
            self.autoScrollTimer = nil
        }

        // 外部アプリ起動要求
        if (url.absoluteString.range(of: AppConst.URL.ITUNES_STORE) != nil) ||
            (!url.absoluteString.hasPrefix("about:") && !url.absoluteString.hasPrefix("http:") && !url.absoluteString.hasPrefix("https:") && !url.absoluteString.hasPrefix("file:")) {
            log.warning("open url. url: \(url)")
            if UIApplication.shared.canOpenURL(url) {
                NotificationManager.presentActionSheet(title: "", message: MessageConst.ALERT.OPEN_COMFIRM, completion: {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }, cancel: nil)
            } else {
                log.warning("cannot open url. url: \(url)")
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(_: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url?.absoluteString {
                log.debug("receive new window event. url: \(url)")

                isSelectingNewTabEvent = true

                // 150文字以上は省略
                let message = url.count > 50 ? String(url.prefix(200)) + "..." : url
                NotificationManager.presentActionSheet(title: MessageConst.NOTIFICATION.NEW_TAB, message: message, completion: {
                    self.isSelectingNewTabEvent = false
                    self.viewModel.insertTab(url: navigationAction.request.url?.absoluteString)
                }, cancel: {
                    self.isSelectingNewTabEvent = false
                })

//                if url != AppConst.URL.BLANK {
//                    // about:blankは無視する
//                    viewModel.insertPageHistoryDataModel(url: navigationAction.request.url?.absoluteString)
//                } else {
//                    log.warning("about blank event.")
//                }
                return nil
            }
        }
        return nil
    }
}
