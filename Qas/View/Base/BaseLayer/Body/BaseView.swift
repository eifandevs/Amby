//
//  BaseViewControllerViewModel.swift
//  Eiger
//
//  Created by temma on 2017/02/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import WebKit

protocol BaseViewDelegate: class {
    func baseViewDidScroll(speed: CGFloat)
    func baseViewDidChangeFront()
    func baseViewDidTouchBegan()
    func baseViewDidTouchEnd()
    func baseViewDidEdgeSwiped(direction: EdgeSwipeDirection)
}

enum EdgeSwipeDirection: CGFloat {
    case right = 1
    case left = -1
    case none = 0
}

class BaseView: UIView {
    
    weak var delegate: BaseViewDelegate?

    /// 編集状態にするクロージャ
    private var beginEditingWorkItem: DispatchWorkItem?
    
    /// 最前面のWebView
    private var front: EGWebView! {
        didSet {
            if let _ = front {
                // 移動量の初期化
                scrollMovingPointY = 0
                // プライベートモードならデザインを変更する
                delegate?.baseViewDidChangeFront()
                // ヘッダーフィールドを更新する
                viewModel.reloadHeaderText()
                // 空ページの場合は、編集状態にする
                if viewModel.currentUrl.isEmpty {
                    if let beginEditingWorkItem = self.beginEditingWorkItem {
                        beginEditingWorkItem.cancel()
                    }
                    beginEditingWorkItem = DispatchWorkItem() { [weak self] in
                        guard let `self` = self else { return }
                        self.viewModel.beginEditingHeaderViewDataModel()
                        self.beginEditingWorkItem = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: beginEditingWorkItem!)
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
    private var isDoneAutoInput = false
    /// タッチ中フラグ
    private var isTouching = false
    /// 自動スクロール
    private var autoScrollTimer: Timer? = nil
    /// スワイプ方向
    private var swipeDirection: EdgeSwipeDirection = .none
    /// タッチ開始位置
    private var touchBeganPoint: CGPoint?
    /// スワイプでページ切り替えを検知したかどうかのフラグ
    private var isChangingFront: Bool = false

    /// ベースビューがMaxポジションにあるかどうかのフラグ
    var isLocateMax: Bool {
        return frame.origin.y == AppConst.BASE_LAYER_HEADER_HEIGHT
    }
    /// ベースビューがMinポジションにあるかどうかのフラグ
    var isLocateMin: Bool {
        return frame.origin.y == DeviceConst.STATUS_BAR_HEIGHT
    }
    /// 逆順方向のスクロールが可能かどうかのフラグ
    var canPastScroll: Bool {
        return front.scrollView.contentOffset.y > 0
    }
    ///順方向のスクロールが可能かどうかのフラグ
    var canForwardScroll: Bool {
        return front.scrollView.contentOffset.y < front.scrollView.contentSize.height - front.frame.size.height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewModel.delegate = self
        EGApplication.sharedMyApplication.egDelegate = self
        
        // webviewsに初期値を入れる
        for _ in 0...viewModel.webViewCount - 1 {
            webViews.append(nil)
        }
        
        let newWv = createWebView(size: frame.size, context: viewModel.currentContext)
        webViews[viewModel.currentLocation] = newWv
        
        // 前後のページ
        previousImageView.frame = CGRect(origin: CGPoint(x: -frame.size.width, y: 0), size: frame.size)
        nextImageView.frame = CGRect(origin: CGPoint(x: frame.size.width, y: 0), size: frame.size)
        addSubview(previousImageView)
        addSubview(nextImageView)
        
        // ロードする
        if !viewModel.currentUrl.isEmpty {
            _ = newWv.load(urlStr: viewModel.currentUrl)
        } else {
            // 1秒後にwillBeginEditingする
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.beginEditingHeaderViewDataModel()
            }
        }
    }
    
    deinit {
        log.debug("deinit called.")
        webViews.forEach { (webView) in
            if let unwrappedWebView = webView {
                if unwrappedWebView == front {
                    unwrappedWebView.removeObserver(self, forKeyPath: "estimatedProgress")
                }
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: KVO(Progress)
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            //estimatedProgressが変更されたときに、プログレスバーの値を変更する。
            viewModel.updateProgressHeaderViewDataModel(object: CGFloat(front.estimatedProgress))
        }
    }
    
// MARK: Public Method
    func getFrontUrl() -> String? {
        return front.url?.absoluteString
    }
    
    func slide(value: CGFloat) {
        frame.origin.y += value
        // スライドと同時にスクロールが発生しているので、逆方向にスクロールし、スクロールを無効化する
        front.scrollView.setContentOffset(CGPoint(x: front.scrollView.contentOffset.x, y: front.scrollView.contentOffset.y + value), animated: false)
    }

    func slideToMax() {
        frame.origin.y = AppConst.BASE_LAYER_HEADER_HEIGHT
    }
    
    func slideToMin() {
        frame.origin.y = DeviceConst.STATUS_BAR_HEIGHT
    }
    
    func validateUserInteraction() {
        isUserInteractionEnabled = true
        EGApplication.sharedMyApplication.egDelegate = self
        webViews.forEach { (wv: EGWebView?) in
            if let wv = wv, !wv.scrollView.isScrollEnabled {
                wv.scrollView.isScrollEnabled = true
                wv.scrollView.bounces = true
            }
        }
    }
    
// MARK: Private Method
    
    private func updateNetworkActivityIndicator() {
        let loadingWebViews: [EGWebView?] = webViews.filter({ (wv) -> Bool in
            if let wv = wv {
                return wv.isLoading
            }
            return false;
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
    
    private func startProgressObserving(target: EGWebView) {
        log.debug("start progress observe. target: \(target.context)")

        //プログレスが変更されたことを取得
        target.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &(target.context))
        if target.isLoading == true {
            viewModel.updateProgressHeaderViewDataModel(object: CGFloat(target.estimatedProgress))
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = target.isLoading
    }
    
    /// webviewを新規作成
    private func createWebView(size: CGSize? = nil, context: String?) -> EGWebView {
        let newWv = EGWebView(id: context)
        newWv.frame = CGRect(origin: CGPoint.zero, size: size ?? frame.size)
        newWv.navigationDelegate = self
        newWv.uiDelegate = self
        newWv.scrollView.delegate = self
        front = newWv
        Util.createFolder(path: Util.thumbnailFolderPath(folder: newWv.context))
        addSubview(newWv)

        // プログレスバー
        startProgressObserving(target: newWv)
        
        return newWv
    }
    
    // loadWebViewはwebviewスペースがある状態で新規作成するときにコールする
    private func loadWebView() {
        let newWv = createWebView(context: viewModel.currentContext)
        webViews[viewModel.currentLocation] = newWv
        if !viewModel.currentUrl.isEmpty {
            newWv.load(urlStr: viewModel.currentUrl)
        }
    }
    
    /// ページ情報保存
    private func saveMetaData(webView: EGWebView) {
        if let urlStr = webView.url?.absoluteString, let title = webView.title, !title.isEmpty {
            if urlStr.hasValidUrl {
                webView.requestUrl = urlStr
                webView.requestTitle = title
                if webView == front {
                    viewModel.headerFieldText = webView.requestUrl
                }
            } else if urlStr.hasLocalUrl {
                // エラーが発生した時のheaderField更新
                if webView == front {
                    viewModel.headerFieldText = viewModel.latestRequestUrl
                }
            }
        }
    }
    
    private func saveThumbnail(webView: EGWebView, completion: @escaping (() -> ())) {
        // サムネイルを保存
        DispatchQueue.mainSyncSafe {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                webView.takeSnapshot(with: nil) { image, error in
                    if let img = image {
                        let pngImageData = UIImagePNGRepresentation(img)
                        let context = webView.context
                        do {
                            try pngImageData?.write(to: Util.thumbnailUrl(folder: context))
                            log.debug("save thumbnal. context: \(context)")
                            completion()
                        } catch let error as NSError {
                            log.error("failed to store thumbnail: \(error)")
                            completion()
                        }
                    } else {
                        log.error("failed taking snapshot. error: \(error?.localizedDescription)")
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
            if (front.scrollView.contentOffset.y >= bottomOffset) {
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
        isTouching = true
        delegate?.baseViewDidTouchBegan()
        touchBeganPoint = touch.location(in: self)
        isChangingFront = false
        if touchBeganPoint!.x < AppConst.FRONT_LAYER_EDGE_SWIPE_EREA {
            swipeDirection = .left
        } else if touchBeganPoint!.x > self.bounds.size.width - AppConst.FRONT_LAYER_EDGE_SWIPE_EREA {
            swipeDirection = .right
        } else {
            swipeDirection = .none
        }
    }
    
    internal func screenTouchMoved(touch: UITouch) {
        if let touchBeganPoint = touchBeganPoint, front.scrollView.isScrollEnabled {
            let touchPoint = touch.location(in: self)
            if ((swipeDirection == .left && touchPoint.x > AppConst.FRONT_LAYER_EDGE_SWIPE_EREA + 20) ||
                (swipeDirection == .right && touchPoint.x < self.bounds.width - AppConst.FRONT_LAYER_EDGE_SWIPE_EREA - 20)) {
                // エッジスワイプ検知
                // TODO: 動画DL
//                self.front.evaluateJavaScript("document.querySelector('video').currentSrc") { (object, error) in
//                    log.warning("object: \(object)")
//                }
                
                if viewModel.getBaseViewControllerStatus() {
                    invalidateUserInteraction()
                    delegate?.baseViewDidEdgeSwiped(direction: swipeDirection)
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
    
    internal func screenTouchEnded(touch: UITouch) {
        isTouching = false
        if isChangingFront {
            isChangingFront = false
            let targetOriginX = {() -> CGFloat in
                if frame.origin.x  > frame.size.width / 3 {
                    return frame.size.width
                } else if frame.origin.x < -(frame.size.width / 3) {
                    return -frame.size.width
                } else {
                    return 0
                }
            }()
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.x = targetOriginX
            }, completion: { (finished) in
                if finished {
                    // 入れ替える
                    if targetOriginX == self.frame.size.width {
                        // 前のwebviewに遷移
                        self.viewModel.changePreviousWebView()
                    } else if targetOriginX == -self.frame.size.width {
                        self.viewModel.changeNextWebView()
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
        isTouching = false
        screenTouchEnded(touch: touch)
    }
}

// MARK: ScrollView Delegate
extension BaseView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // フロントのみ通知する
        if let front = front {
            if front.scrollView == scrollView {
                if scrollMovingPointY != 0 {
                    let isOverScrolling = (scrollView.contentOffset.y <= 0) || (scrollView.contentOffset.y >= scrollView.contentSize.height - frame.size.height)
                    let speed = scrollView.contentOffset.y - scrollMovingPointY
                    if (scrollMovingPointY != 0 && !isOverScrolling || (canForwardScroll && isOverScrolling && speed < 0) || (isOverScrolling && speed > 0 && scrollView.contentOffset.y > 0)) {
                        delegate?.baseViewDidScroll(speed: -1 * speed)
                    }
                }
                scrollMovingPointY = scrollView.contentOffset.y
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // フロントのみ通知する
        if let front = front {
            if front.scrollView == scrollView {
                if velocity.y == 0 && !isTouching {
                    delegate?.baseViewDidTouchEnd()
                    scrollMovingPointY = 0
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // フロントのみ通知する
        if let front = front {
            if front.scrollView == scrollView {
                if !isTouching {
                    delegate?.baseViewDidTouchEnd()
                    scrollMovingPointY = 0
                }
            }
        }
    }
}

// MARK: BaseViewModel Delegate
extension BaseView: BaseViewModelDelegate {
    func baseViewModelDidAutoInput() {
        if !isDoneAutoInput {
            if let inputForm = FormDataModel.s.select(url: front.url?.absoluteString).first {
                NotificationManager.presentAlert(title: MessageConst.ALERT_FORM_TITLE, message: MessageConst.ALERT_FORM_EXIST, completion: { [weak self] in
                    for input in inputForm.inputs {
                        let value = EncryptHelper.decrypt(serviceToken: CommonDao.s.keychainServiceToken, ivToken: CommonDao.s.keychainIvToken, data: input.value)!
                        self!.front.evaluateJavaScript("document.forms[\(input.formIndex)].elements[\(input.formInputIndex)].value=\"\(value)\"") { (object, error) in
                        }
                    }
                })
                isDoneAutoInput = true
            }
        }
    }
    
    func baseViewModelDidAddWebView() {
        if let front = front {
            // 全てのwebviewが削除された場合
            front.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        viewModel.updateProgressHeaderViewDataModel(object: 0)
        let newWv = createWebView(context: viewModel.currentContext)
        webViews.append(newWv)
        if viewModel.currentUrl.isEmpty {
            // 編集状態にする
            if let beginEditingWorkItem = self.beginEditingWorkItem {
                beginEditingWorkItem.cancel()
            }
            beginEditingWorkItem = DispatchWorkItem() { [weak self]  in
                guard let `self` = self else { return }
                self.viewModel.beginEditingHeaderViewDataModel()
                self.beginEditingWorkItem = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: beginEditingWorkItem!)
        } else {
            _ = newWv.load(urlStr: viewModel.currentUrl)
        }
    }
    
    func baseViewModelDidReloadWebView() {
        if front.hasValidUrl {
            front.reload()
        } else {
            _ = front.load(urlStr: viewModel.reloadUrl)
        }
    }
    
    func baseViewModelDidChangeWebView() {
        front.removeObserver(self, forKeyPath: "estimatedProgress")
        viewModel.updateProgressHeaderViewDataModel(object: 0)
        if let current = webViews[viewModel.currentLocation] {
            current.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &(current.context))
            if current.isLoading == true {
                viewModel.updateProgressHeaderViewDataModel(object: CGFloat(current.estimatedProgress))
            }
            front = current
            bringSubview(toFront: current)
        } else {
            loadWebView()
        }
    }
    
    /// ページ削除通知
    /// context: 削除したコンテキスト
    func baseViewModelDidRemoveWebView(context: String, pageExist: Bool, deleteIndex: Int) {
        if let webView = webViews[deleteIndex] {
            // サムネイルの削除
            viewModel.deleteThumbnail(webView: webView)
            
            let isFrontDelete = context == front.context
            if isFrontDelete {
                webView.removeObserver(self, forKeyPath: "estimatedProgress")
                viewModel.updateProgressHeaderViewDataModel(object: 0)
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
            
            if isFrontDelete && pageExist {
                // フロントの削除で、削除後にwebviewが存在する場合
                
                if let current = D.find(webViews, callback: { $0?.context == PageHistoryDataModel.s.currentContext }) {
                    current!.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &(current!.context))
                    front = current
                    bringSubview(toFront: current!)
                } else {
                    loadWebView()
                }
            }
        }
    }
    
    func baseViewModelDidSearchWebView(text: String) {
        if text.hasValidUrl {
            let encodedText = text.contains("%") ? text : text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            viewModel.headerFieldText = encodedText
            _ = front.load(urlStr: encodedText)
        } else {
            // 検索ワードによる検索
            // 閲覧履歴を保存する
            viewModel.storeSearchHistoryDataModel(title: text)
            let encodedText = "\(AppConst.PATH_SEARCH)\(text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)"
            viewModel.headerFieldText = encodedText
            _ = front.load(urlStr: encodedText)
        }
    }
    
    func baseViewModelDidHistoryBackWebView() {
        if front.isLoading && front.operation == .normal && !(viewModel.getPastViewingPageHistoryDataModel(context: front.context)) {
            // 新規ページ表示中に戻るを押下したルート
            log.debug("go back on loading.")
            
            if let url = viewModel.getMostForwardUrlPageHistoryDataModel(context: front.context) {
                front.operation = .back
                _ = front.load(urlStr: url)
            }
        } else {
            log.debug("go back.")
            // 有効なURLを探す
            if let url = viewModel.getBackUrlPageHistoryDataModel(context: front.context) {
                front.operation = .back
                _ = front.load(urlStr: url)
            }
        }
    }
    
    func baseViewModelDidHistoryForwardWebView() {
        // 有効なURLを探す
        if let url = viewModel.getForwardUrlPageHistoryDataModel(context: front.context) {
            front.operation = .forward
            _ = front.load(urlStr: url)
        }
    }
    
    func baseViewModelDidRegisterAsForm() {
        self.viewModel.storeFromDataModel(webview: front)
    }
    
    func baseViewModelDidAutoScroll() {
        if autoScrollTimer != nil || autoScrollTimer?.isValid == true {
            autoScrollTimer?.invalidate()
            autoScrollTimer = nil
        } else {
            autoScrollTimer = Timer.scheduledTimer(timeInterval: Double(viewModel.autoScrollInterval), target: self, selector: #selector(self.updateAutoScrolling), userInfo: nil, repeats: true)
            autoScrollTimer?.fire()
        }
    }
}

// MARK: WKNavigationDelegate, UIWebViewDelegate, WKUIDelegate
extension BaseView: WKNavigationDelegate, UIWebViewDelegate, WKUIDelegate {
    
    /// force touchを無効にする
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let wv = webView as! EGWebView
        log.debug("loading start. context: \(wv.context)")
        
        if wv.context == front.context {
            // フロントwebviewの通知なので、プログレスを更新する
            //インジゲーターの表示、非表示をきりかえる。
            viewModel.startLoadingPageHistoryDataModel(context: wv.context)
            viewModel.updateProgressHeaderViewDataModel(object: CGFloat(0.1))
            // くるくるを更新する
            updateNetworkActivityIndicator()
        } else {
            //インジゲーターの表示、非表示をきりかえる。
            viewModel.startLoadingPageHistoryDataModel(context: wv.context)
            // くるくるを更新する
            updateNetworkActivityIndicator()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let wv = webView as! EGWebView
        log.debug("loading finish. context: \(wv.context)")
        
        // 削除済みチェック
        guard let _ = self.viewModel.getIndex(context: wv.context) else {
            log.warning("loading finish on deleted page.")
            return
        }
        
        // 操作種別の保持
        let operation = wv.operation
        
        // 操作種別はnormalに戻しておく
        if wv.operation != .normal {
            wv.operation = .normal
        }
        
        // ページ情報を取得
        saveMetaData(webView: wv)
        
        if wv.hasSavableUrl {
            isDoneAutoInput = false
            // 有効なURLの場合は、履歴に保存する
            viewModel.updateHistoryDataModel(context: wv.context, url: wv.requestUrl, title: wv.requestTitle, operation: operation)
            viewModel.storePageHistoryDataModel()
        }
        
        if wv.requestUrl != nil {
            wv.previousUrl = wv.requestUrl
        }
        
        // プログレス更新
        if wv.context == front.context {
            viewModel.updateProgressHeaderViewDataModel(object: 1.0)
        }
        updateNetworkActivityIndicator()
        viewModel.endLoadingPageHistoryDataModel(context: wv.context)
        
        // サムネイルを保存
        self.saveThumbnail(webView: wv, completion: {
            // プログレス更新
            self.viewModel.endRenderingPageHistoryDataModel(context: wv.context)
        })
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        log.error("[error url]\((error as NSError).userInfo["NSErrorFailingURLKey"]). code: \((error as NSError).code)")
        
        let egWv: EGWebView = webView as! EGWebView
        
        // 連打したら-999 "(null)"になる対応
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }
        
        // プログレス更新
        DispatchQueue.mainSyncSafe {
            // プログレス更新
            if egWv.context == front.context {
                viewModel.updateProgressHeaderViewDataModel(object: 0)
            }
            self.updateNetworkActivityIndicator()
            self.viewModel.endLoadingPageHistoryDataModel(context: egWv.context)
        }
        
        // URLスキーム対応
        if let errorUrl = (error as NSError).userInfo["NSErrorFailingURLKey"] {
            let url = (errorUrl as! NSURL).absoluteString!
            if !url.hasValidUrl || url.range(of: AppConst.URL_ITUNES_STORE) != nil {
                log.warning("load error. [open url event]")
                return
            }
        }
        
        egWv.loadHtml(error: (error as NSError))
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let egWv: EGWebView = webView as! EGWebView
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            // SSL認証
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential);
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
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                completionHandler(.cancelAuthenticationChallenge, nil)
                egWv.loadHtml(code: .UNAUTHORIZED)
            }))
            alertController.addAction(UIAlertAction(title: "Log In", style: .default, handler: { action in
                let credential = URLCredential(user: usernameTextField.text!, password: passwordTextField.text!, persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, credential)
            }))
            Util.foregroundViewController().present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        // 自動スクロールを停止する
        if let autoScrollTimer = autoScrollTimer, autoScrollTimer.isValid {
            autoScrollTimer.invalidate()
            self.autoScrollTimer = nil
        }
        
        // 外部アプリ起動要求
        if ((url.absoluteString.range(of: AppConst.URL_ITUNES_STORE) != nil) ||
            (!url.absoluteString.hasPrefix("about:") && !url.absoluteString.hasPrefix("http:") && !url.absoluteString.hasPrefix("https:") && !url.absoluteString.hasPrefix("file:"))) {
            log.warning("open url. url: \(url)")
            if UIApplication.shared.canOpenURL(url) {
                NotificationManager.presentActionSheet(title: "", message: MessageConst.ALERT_OPEN_COMFIRM, completion: {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                })
            } else {
                log.warning("cannot open url. url: \(url)")
            }
            decisionHandler(.cancel)
            return
        }
        
        // リクエストURLはエラーが発生した時のため保持しておく
        // エラー発生時は、リクエストしたURLを履歴に保持する
        if let latest = navigationAction.request.url?.absoluteString, latest.hasValidUrl {
            log.debug("[Request Url]: \(latest)")
            viewModel.latestRequestUrl = latest
        }
        
        saveMetaData(webView: webView as! EGWebView)
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url?.absoluteString {
                log.debug("receive new window event. url: \(url)")
                
                viewModel.insertPageHistoryDataModel(url: navigationAction.request.url?.absoluteString)

//                if url != AppConst.URL_BLANK {
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
