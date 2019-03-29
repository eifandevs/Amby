//
//  BaseViewControllerViewModel.swift
//  Eiger
//
//  Created by temma on 2017/02/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import CommonUtil
import Entity
import Foundation
import Model
import RxCocoa
import RxSwift
import UIKit
import WebKit

enum EdgeSwipeDirection: CGFloat {
    case right = 1
    case left = -1
    case none = 0
}

enum BaseViewAction {
    case changeFront
    case slide(distance: CGFloat)
    case slideToMax
    case slideToMin
    case swipe(direction: EdgeSwipeDirection)
}

class BaseView: UIView {
    /// アクション通知用RX
    let rx_action = PublishSubject<BaseViewAction>()

    /// 編集状態にするクロージャ
    private var beginSearchingWorkItem: DispatchWorkItem?

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
                rx_action.onNext(.changeFront)
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
    /// 自動スクロール
    private var autoScrollTimer: Timer?
    /// タッチ開始位置
    private var touchBeganPoint: CGPoint?

    /// 初期化済みフラグ
    var isBuilt: Bool {
        return webViews.count > 0
    }

    /// スライド中かどうかのフラグ
    var isMoving: Bool {
        return !isLocateMax && !isLocateMin
    }

    /// ベースビューがMaxポジションにあるかどうかのフラグ
    var isLocateMax: Bool {
        return frame.origin.y == viewModel.positionY.max
    }

    /// ベースビューがMinポジションにあるかどうかのフラグ
    var isLocateMin: Bool {
        return frame.origin.y == viewModel.positionY.min
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        setupRx()
    }

    private func setupTabs() {
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
    }

    private func removeTabs() {
        webViews.forEach { webView in
            if let unwrappedWebView = webView {
                removeObserving(target: unwrappedWebView)
                unwrappedWebView.removeFromSuperview()
            }
        }
        webViews.removeAll()
        NotificationCenter.default.removeObserver(self)
    }

    private func setup() {
        // タッチイベントを監視
        EGApplication.sharedMyApplication.egDelegate = self

        // 前後のページ
        previousImageView.frame = CGRect(origin: CGPoint(x: -frame.size.width, y: 0), size: frame.size)
        nextImageView.frame = CGRect(origin: CGPoint(x: frame.size.width, y: 0), size: frame.size)
        addSubview(previousImageView)
        addSubview(nextImageView)
    }

    private func setupRx() {
        // アクション監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                log.eventIn(chain: "baseViewModel.rx_action. action: \(action)")

                switch action {
                case let .insert(at): self.insert(at: at)
                case .reload: self.reload()
                case .rebuild: self.rebuild()
                case let .append(currentHistory): self.append(currentHistory: currentHistory)
                case .change: self.change()
                case let .swap(start, end): self.swap(start: start, end: end)
                case let .remove(isFront, deleteContext, currentContext, deleteIndex): self.remove(isFront: isFront, deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex)
                case .historyBack: self.historyBack()
                case .historyForward: self.historyForward()
                case let .load(url): self.load(url: url)
                case .form: self.takeForm()
                case .autoScroll: self.autoScroll()
                case .autoFill: self.autoFill()
                case .scrollUp: self.scrollUp()
                case let .grep(text): self.grep(text: text)
                case let .grepPrevious(index), let .grepNext(index): self.grepScroll(index: index)
                case let .analysisHtml(url): self.analysisHtml(url: url)
                }
                log.eventOut(chain: "baseViewModel.rx_action. action: \(action)")
            }
            .disposed(by: rx.disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        removeTabs()
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
                    viewModel.updatePageUrl(context: contextPtr.pointee, url: url.absoluteString)
                }
            } else if keyPath == "canGoBack" {
                log.debug("receive canGoBack change.")
                if let change = change, let canGoBack = change[NSKeyValueChangeKey.newKey] as? Bool {
                    viewModel.updateCanGoBack(context: contextPtr.pointee, canGoBack: canGoBack)
                }
            } else if keyPath == "canGoForward" {
                log.debug("receive canGoFoward change.")
                if let change = change, let canGoFoward = change[NSKeyValueChangeKey.newKey] as? Bool {
                    viewModel.updateCanGoForward(context: contextPtr.pointee, canGoForward: canGoFoward)
                }
            }
        }
    }

    // MARK: Public Method

    func getFrontUrl() -> String? {
        return front.url?.absoluteString
    }

    /// 高さの最大位置までスライド
    func slideToMax() {
        if !isLocateMax {
            rx_action.onNext(.slideToMax)
            frame.origin.y = AppConst.BASE_LAYER.HEADER_HEIGHT
            scaleToMin()
        }
    }

    /// 高さの最小位置までスライド
    func slideToMin() {
        if !isLocateMin {
            rx_action.onNext(.slideToMin)
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

    private func grep(text: String) {
        front.highlight(word: text)
            .then { hitNum in
                if let hitNum = hitNum as? NSNumber {
                    let num = Int(truncating: hitNum)
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.GREP_SUCCESS(num), isSuccess: true)
                    self.viewModel.endGrepping(hitNum: num)
                }
            }.catch { _ in
                NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.GREP_ERROR, isSuccess: false)
            }
    }

    private func grepScroll(index: Int) {
        front.scrollIntoViewWithIndex(index: index)
            .catch { _ in
                NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.GREP_SCROLL_ERROR, isSuccess: false)
            }
    }

    private func analysisHtml(url: String) {
        if let url = URL(string: "\(AppConst.URL.ANALYSIS_URL_PREFIX)\(url)") {
            front.load(URLRequest(url: url))
        }
//        front.analysisHtml()
//            .then { _ in
//                self.front.loadShaperHtml()
//            }
    }

    private func scrollUp() {
        _ = DispatchQueue.mainSyncSafe {
            self.front.scrollUp().then { _ in }
        }
    }

    private func autoScroll() {
        if autoScrollTimer != nil || autoScrollTimer?.isValid == true {
            autoScrollTimer?.invalidate()
            autoScrollTimer = nil
        } else {
            autoScrollTimer = Timer.scheduledTimer(timeInterval: Double(viewModel.autoScrollInterval), target: self, selector: #selector(updateAutoScrolling), userInfo: nil, repeats: true)
            autoScrollTimer?.fire()
        }
    }

    private func takeForm() {
        if let form = self.viewModel.takeForm(webView: self.front) {
            viewModel.storeForm(form: form)
        } else {
            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.REGISTER_FORM_ERROR_CRAWL, isSuccess: false)
        }
    }

    private func historyForward() {
        log.debug("go forward.")
        if front.canGoForward {
            front.goForward()
        }
    }

    private func historyBack() {
        log.debug("go back.")
        if front.canGoBack {
            front.goBack()
        }
    }

    private func load(url: String) {
        _ = front.load(urlStr: url)
    }

    private func remove(isFront: Bool, deleteContext _: String, currentContext: String?, deleteIndex: Int) {
        if let webView = self.webViews[deleteIndex] {
            if isFront {
                webView.removeObserverEstimatedProgress(observer: self)
                viewModel.updateProgress(progress: 0)
                front = nil
            }

            // ローディングキャンセル
            if webView.isLoading {
                webView.stopLoading()
            }

            webView.removeFromSuperview()
            webViews.remove(at: deleteIndex)

            // くるくるを更新
            updateNetworkActivityIndicator()

            if isFront && currentContext != nil {
                // フロントの削除で、削除後にwebviewが存在する場合
                if let current = self.webViews.find({ $0?.context == currentContext }), let currentWebView = current {
                    currentWebView.observeEstimatedProgress(observer: self)
                    front = current
                    bringSubview(toFront: currentWebView)
                } else {
                    loadWebView()
                }
            }
        }
    }

    private func reload() {
        if front.isValidUrl {
            front.reload()
        } else {
            if let url = self.viewModel.currentUrl {
                _ = front.load(urlStr: url)
            }
        }
    }

    private func rebuild() {
        // 再構築
        removeTabs()
        setupTabs()
    }

    private func change() {
        if let currentLocation = self.viewModel.currentLocation {
            front.removeObserverEstimatedProgress(observer: self)
            viewModel.updateProgress(progress: 0)

            if let current = self.webViews[currentLocation] {
                current.observeEstimatedProgress(observer: self)
                if current.isLoading == true {
                    viewModel.updateProgress(progress: CGFloat(current.estimatedProgress))
                }
                front = current
                bringSubview(toFront: current)
            } else {
                loadWebView()
            }
        } else {
            log.error("cannot find current location.")
        }
    }

    private func swap(start: Int, end: Int) {
        webViews = webViews.move(from: start, to: end)
    }

    private func insert(at: Int) {
        // 現フロントのプログレス監視を削除
        if let front = self.front {
            front.removeObserverEstimatedProgress(observer: self)
        }
        viewModel.updateProgress(progress: 0)
        let newWv = createWebView(context: viewModel.currentContext)
        webViews.insert(newWv, at: at)
        if viewModel.currentUrl.isEmpty {
            // 編集状態にする
            if let beginSearchingWorkItem = self.beginSearchingWorkItem {
                beginSearchingWorkItem.cancel()
            }
            beginSearchingWorkItem = DispatchWorkItem { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.beginSearching()
                self.beginSearchingWorkItem = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: beginSearchingWorkItem!)
        } else {
            if let url = self.viewModel.currentUrl {
                _ = newWv.load(urlStr: url)
            } else {
                log.error("cannot get currentUrl.")
            }
        }
    }

    private func append(currentHistory: PageHistory) {
        // 現フロントのプログレス監視を削除
        if let front = self.front {
            front.removeObserverEstimatedProgress(observer: self)
        }
        viewModel.updateProgress(progress: 0)
        let newWv = createWebView(context: currentHistory.context)
        webViews.append(newWv)
        if currentHistory.url.isEmpty {
            // 編集状態にする
            if let beginSearchingWorkItem = self.beginSearchingWorkItem {
                beginSearchingWorkItem.cancel()
            }
            beginSearchingWorkItem = DispatchWorkItem { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.beginSearching()
                self.beginSearchingWorkItem = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: beginSearchingWorkItem!)
        } else {
            if !currentHistory.url.isEmpty {
                _ = newWv.load(urlStr: currentHistory.url)
            } else {
                log.error("cannot get currentUrl.")
            }
        }
    }

    private func autoFill() {
        if !viewModel.state.contains(.isDoneAutoFill) {
            if let url = self.front.url?.absoluteString, let inputForm = self.viewModel.selectForm(url: url) {
                NotificationService.presentAlert(title: MessageConst.ALERT.FORM_TITLE, message: MessageConst.ALERT.FORM_EXIST, completion: { [weak self] in
                    guard let `self` = self else { return }
                    inputForm.inputs.forEach {
                        let value = self.viewModel.decrypt(value: $0.value)
                        let input = $0
                        // set form
                        DispatchQueue.mainSyncSafe {
                            _ = self.front.evaluate(script: "document.forms[\(input.formIndex)].elements[\(input.formInputIndex)].value='\(value)'")
                        }
                    }
                })
                viewModel.state.insert(.isDoneAutoFill)
            }
        }
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

    private func removeObserving(target: EGWebView) {
        target.removeObserverEstimatedProgress(observer: self)
        target.removeObserverTitle(observer: self)
        target.removeObserverUrl(observer: self)
        target.removeObserverCanGoBack(observer: self)
        target.removeObserverCanGoForward(observer: self)
    }

    private func startObserving(target: EGWebView) {
        log.debug("start observe. target: \(target.context)")

        target.observeEstimatedProgress(observer: self)
        target.observeTitle(observer: self)
        target.observeUrl(observer: self)
        target.observeCanGoBack(observer: self)
        target.observeCanGoForward(observer: self)

        if target.isLoading == true {
            viewModel.updateProgress(progress: CGFloat(target.estimatedProgress))
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = target.isLoading
    }

    /// webviewを新規作成
    private func createWebView(size: CGSize? = nil, context: String?) -> EGWebView {
        let newWv = EGWebView(id: context, configuration: viewModel.cacheConfiguration)
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

    private func slide(value: CGFloat) {
        rx_action.onNext(.slide(distance: value))
        frame.origin.y += value
        front.frame.size.height -= value
        // スライドと同時にスクロールが発生しているので、逆方向にスクロールし、スクロールを無効化する
        front.scrollView.setContentOffset(CGPoint(x: front.scrollView.contentOffset.x, y: front.scrollView.contentOffset.y + value), animated: false)
    }

    /// サイズの最大化
    private func scaleToMax() {
        frame.size.height = AppConst.BASE_LAYER.BASE_HEIGHT
        front.frame.size.height = AppConst.BASE_LAYER.BASE_HEIGHT
    }

    /// サイズの最小化
    private func scaleToMin() {
        frame.size.height = AppConst.BASE_LAYER.BASE_HEIGHT - AppConst.BASE_LAYER.HEADER_HEIGHT + AppConst.DEVICE.STATUS_BAR_HEIGHT
        front.frame.size.height = AppConst.BASE_LAYER.BASE_HEIGHT - AppConst.BASE_LAYER.HEADER_HEIGHT + AppConst.DEVICE.STATUS_BAR_HEIGHT
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
            viewModel.state.remove(.isTouching)
            return
        }

        viewModel.state.insert(.isTouching)
        viewModel.state.remove(.isChangingFront)

        touchBeganPoint = touch.location(in: self)

        viewModel.readySwipeDirection(touchBeganPoint: touchBeganPoint)
    }

    internal func screenTouchMoved(touch: UITouch) {
        if !viewModel.state.contains(.isTouching) { return }

        if let touchBeganPoint = touchBeganPoint, front.scrollView.isScrollEnabled {
            let touchPoint = touch.location(in: self)
            if viewModel.isEdgeSwiped(touchPoint: touchPoint) {
                // エッジスワイプ検知
                if !viewModel.moveHistoryIfHistorySwipe(touchPoint: touchBeganPoint) {
                    // 操作を無効化
                    invalidateUserInteraction()

                    rx_action.onNext(.swipe(direction: viewModel.swipeDirection))
                }
            }

            if webViews.count > 1 && viewModel.swipeDirection == .none && front.isSwiping {
                // フロントの左右に切り替え後のページを表示しとく
                if previousImageView.image == nil && nextImageView.image == nil {
                    previousImageView.image = viewModel.getPreviousCapture()
                    nextImageView.image = viewModel.getNextCapture()
                }
                if viewModel.state.contains(.isChangingFront) {
                    let previousTouchPoint = touch.previousLocation(in: self)
                    let distance: CGPoint = touchPoint - previousTouchPoint
                    frame.origin.x += distance.x
                } else {
                    if touchBeganPoint.y != -1 {
                        if fabs(touchPoint.y - touchBeganPoint.y) < 7.5 {
                            // エッジスワイプではないスワイプを検知し、y軸に誤差7.5pxで、x軸に11px移動したらフロントビューの移動をする
                            if fabs(touchPoint.x - touchBeganPoint.x) > 11 {
                                viewModel.state.insert(.isChangingFront)
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
        if !viewModel.state.contains(.isTouching) { return }

        viewModel.state.remove(.isTouching)
        if viewModel.state.contains(.isChangingFront) {
            viewModel.state.remove(.isChangingFront)

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
        viewModel.state.insert(.isScrolling)
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // フロントのみ通知する
        if let front = front, viewModel.state.contains(.isScrolling) {
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
                                if frame.origin.y + speed > viewModel.positionY.max {
                                    // スライドした結果、Maxを超える場合は、調整する
                                    slideToMax()
                                } else {
                                    // コンテンツサイズが画面より小さい場合は、過去スクロールしない
                                    if speed >= 0 || shouldScroll {
                                        if !viewModel.state.contains(.isAnimating) {
                                            slide(value: speed)
                                        }
                                    }
                                }
                            }
                        } else if speed < 0 {
                            // 順方向(未来)のスクロール
                            // ベースビューがスライド可能な場合にスライドさせる
                            if !isLocateMin {
                                if frame.origin.y + speed < viewModel.positionY.min {
                                    // スライドした結果、Minを下回る場合は、調整する
                                    slideToMin()
                                } else {
                                    // コンテンツサイズが画面より小さい場合は、過去スクロールしない
                                    if speed >= 0 || shouldScroll {
                                        if !viewModel.state.contains(.isAnimating) {
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
        if let front = front, front.scrollView == scrollView {
            if velocity.y == 0 && !viewModel.state.contains(.isTouching) {
                // タッチ終了時にベースビューの高さを調整する
                if viewModel.state.contains(.isScrolling) && !viewModel.state.contains(.isAnimating) {
                    viewModel.state.remove(.isScrolling)
                    if isMoving {
                        viewModel.state.insert(.isAnimating)

                        if frame.origin.y > viewModel.positionY.max / 2 {
                            UIView.animate(withDuration: 0.2, animations: {
                                self.slideToMax()
                            }, completion: { finished in
                                if finished {
                                    self.viewModel.state.remove(.isAnimating)
                                }
                            })
                        } else {
                            UIView.animate(withDuration: 0.2, animations: {
                                self.slideToMin()
                            }, completion: { finished in
                                if finished {
                                    self.viewModel.state.remove(.isAnimating)
                                }
                            })
                        }
                    }
                }
                scrollMovingPointY = 0
            }
        }
    }

    /// 慣性スクロールをした場合
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // フロントのみ通知する
        if let front = front, front.scrollView == scrollView {
            if !viewModel.state.contains(.isTouching) && !viewModel.state.contains(.isAnimating) {
                // タッチ終了時にベースビューの高さを調整する
                if viewModel.state.contains(.isScrolling) && !viewModel.state.contains(.isAnimating) {
                    viewModel.state.remove(.isScrolling)
                    if isMoving {
                        viewModel.state.insert(.isAnimating)
                        if frame.origin.y > viewModel.positionY.max / 2 {
                            UIView.animate(withDuration: 0.2, animations: {
                                self.slideToMax()
                            }, completion: { finished in
                                if finished {
                                    self.viewModel.state.remove(.isAnimating)
                                }
                            })
                        } else {
                            UIView.animate(withDuration: 0.2, animations: {
                                self.slideToMin()
                            }, completion: { finished in
                                if finished {
                                    self.viewModel.state.remove(.isAnimating)
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

// MARK: WKNavigationDelegate, UIWebViewDelegate, WKUIDelegate

extension BaseView: WKNavigationDelegate, WKUIDelegate {
    // display alert dialog
    func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "OK", style: .default) {
            _ in completionHandler()
        }
        alertController.addAction(otherAction)
        NotificationService.presentAlert(alertController: alertController)
    }

    // display confirm dialog
    func webView(_: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            _ in completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) {
            _ in completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        NotificationService.presentAlert(alertController: alertController)
    }

    // display prompt dialog
    func webView(_: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame _: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okHandler = { () -> Void in
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            _ in completionHandler("")
        }
        let okAction = UIAlertAction(title: "OK", style: .default) {
            _ in okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        NotificationService.presentAlert(alertController: alertController)
    }

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
            viewModel.state.remove(.isDoneAutoFill)
            viewModel.updateProgress(progress: 1.0)
        }
        updateNetworkActivityIndicator()
        viewModel.endLoading(context: wv.context)

        // サムネイルを保存
        viewModel.saveThumbnailAndEndRendering(webView: wv)

        // TODO: 解析要求か判定
        if let url = wv.url, let scheme = url.scheme, scheme == AppConst.URL.LOCAL_SCHEME, url.path.contains("shaper.html") {
            _ = wv.shape(html: "<html><body>bbb</body></html>").then { _ in }
        }
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

        // aboutスキームは無視
        if let scheme = url.scheme, scheme == AppConst.URL.ABOUT_SCHEME {
            decisionHandler(.cancel)
            return
        }

        // 新規ウィンドウ選択中の場合はキャンセル
        if viewModel.state.contains(.isSelectingNewTabEvent) {
            log.debug("cancel url: \(url)")
            decisionHandler(.cancel)
            return
        }

        // 自動スクロールを停止する
        if let autoScrollTimer = autoScrollTimer, autoScrollTimer.isValid {
            autoScrollTimer.invalidate()
            self.autoScrollTimer = nil
        }

        // 解析要求
        // TODO: 新規windowで開く
        //       通常のページと同じようにhistory back and forwardする
        //       view-source:のようなcustom url schemeを設定し、そのスキームではソースを表示する
        //       common historyには管理しない
        //       このスキームの履歴は起動時に復元しない
        if viewModel.isAnalysisUrl(url: url.absoluteString) {
            decisionHandler(.cancel)
            viewModel.addTab()
            return
        }

        // 外部アプリ起動要求
        if viewModel.openAppIfAppStoreRequest(url: url) {
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    /// 新規ウィンドウイベント
    func webView(_: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url?.absoluteString {
                viewModel.insertTabByReceiveNewWindowEvent(url: url)
            }
        }
        return nil
    }
}
