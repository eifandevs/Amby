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
import Bond

protocol BaseViewDelegate {
    func baseViewDidScroll(speed: CGFloat)
    func baseViewDidChangeFront()
    func baseViewDidTouchBegan()
    func baseViewDidTouchEnd()
    func baseViewDidEdgeSwiped(direction: EdgeSwipeDirection)
    func baseViewWillAutoInput()
}

enum EdgeSwipeDirection: CGFloat {
    case right = 1
    case left = -1
    case none = 0
}

class BaseView: UIView, WKNavigationDelegate, UIScrollViewDelegate, UIWebViewDelegate, WKUIDelegate, EGApplicationDelegate, BaseViewModelDelegate {
    
    var delegate: BaseViewDelegate?

    /// 編集状態にするクロージャ
    var beginEditingWorkItem: DispatchWorkItem? = nil
    
    /// 最前面のWebView
    private var front: EGWebView! {
        didSet {
            if let newValue = front {
                // 移動量の初期化
                scrollMovingPointY = 0
                // プライベートモードならデザインを変更する
                delegate?.baseViewDidChangeFront()
                // ヘッダーフィールドを更新する
                viewModel.reloadHeaderText()
                // 空ページの場合は、編集状態にする
                if viewModel.requestUrl.isEmpty {
                    if let beginEditingWorkItem = self.beginEditingWorkItem {
                        beginEditingWorkItem.cancel()
                    }
                    beginEditingWorkItem = DispatchWorkItem() { [weak self] _  in
                        self!.viewModel.notifyBeginEditing()
                        self!.beginEditingWorkItem = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: beginEditingWorkItem!)
                }
            }
        }
    }
    /// 現在表示中の全てのWebView。アプリを殺して、起動した後などは、WebViewインスタンスは入っていないが、配列のスペースは作成される
    var webViews: [EGWebView?] = []
    private let viewModel = BaseViewModel()
    /// Y軸移動量を計算するための一時変数
    private var scrollMovingPointY: CGFloat = 0
    /// キーボード表示中フラグ
    var isDisplayedKeyBoard = false
    /// 自動入力ダイアログ表示済みフラグ
    private var isDoneAutoInput = false
    /// タッチ中フラグ
    private var isTouching = false
    /// 自動スクロール
    private var autoScrollTimer: Timer? = nil
    /// スワイプ方向
    private var swipeDirection: EdgeSwipeDirection = .none
    
    /// ベースビューがスライド中かどうかのフラグ
    var isMoving: Bool {
        get {
            return !isLocateMax && !isLocateMax
        }
    }

    /// ベースビューがMaxポジションにあるかどうかのフラグ
    var isLocateMax: Bool {
        get {
            return frame.origin.y == AppConst.headerViewHeight
        }
    }
    /// ベースビューがMinポジションにあるかどうかのフラグ
    var isLocateMin: Bool {
        get {
            return frame.origin.y == DeviceConst.statusBarHeight
        }
    }
    /// 逆順方向のスクロールが可能かどうかのフラグ
    var canPastScroll: Bool {
        get {
            return front.scrollView.contentOffset.y > 0
        }
    }
    ///順方向のスクロールが可能かどうかのフラグ
    var canForwardScroll: Bool {
        get {
            return front.scrollView.contentOffset.y < front.scrollView.contentSize.height - front.frame.size.height
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewModel.delegate = self
        EGApplication.sharedMyApplication.egDelegate = self
        
        // キーボード表示の処理(フォームの自動設定)
        registerForKeyboardDidShowNotification { [weak self] (notification, size) in
            self!.delegate?.baseViewWillAutoInput()
        }
        
        registerForKeyboardWillHideNotification { [weak self] (notification) in
            self!.isDisplayedKeyBoard = false
        }
        
        // webviewsに初期値を入れる
        for _ in 0...viewModel.webViewCount - 1 {
            webViews.append(nil)
        }
        
        let newWv = createWebView(context: viewModel.currentContext)
        webViews[viewModel.locationIndex] = newWv
        if !viewModel.requestUrl.isEmpty {
            _ = newWv.load(urlStr: viewModel.requestUrl)
        } else {
            // 1秒後にwillBeginEditingする
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] _ in
                self!.viewModel.notifyBeginEditing()
            }
        }
    }
    
    deinit {        
        webViews.forEach { (webView) in
            if let unwrappedWebView = webView {
                if unwrappedWebView == front {
                    unwrappedWebView.removeObserver(self, forKeyPath: "estimatedProgress")
                }
                unwrappedWebView.removeObserver(self, forKeyPath: "loading")
            }
        }
    }
    
    override func layoutSubviews() {
        front.frame = CGRect(origin: CGPoint.zero, size: frame.size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: EGApplication Delegate
    
    internal func screenTouchBegan(touch: UITouch) {
        isTouching = true
        delegate?.baseViewDidTouchBegan()
        let touchPoint = touch.location(in: self)
        if touchPoint.x < AppConst.edgeSwipeErea {
            swipeDirection = .left
        } else if touchPoint.x > self.bounds.size.width - AppConst.edgeSwipeErea {
            swipeDirection = .right
        } else {
            swipeDirection = .none
        }
    }
    
    internal func screenTouchMoved(touch: UITouch) {
        if front.scrollView.isScrollEnabled {
            let touchPoint = touch.location(in: self)
            if ((swipeDirection == .left && touchPoint.x > AppConst.edgeSwipeErea + 20) ||
                (swipeDirection == .right && touchPoint.x < self.bounds.width - AppConst.edgeSwipeErea - 20)) {
                // エッジスワイプ検知
                invalidateUserInteraction()
                delegate?.baseViewDidEdgeSwiped(direction: swipeDirection)
            }
        }
    }
    
    internal func screenTouchEnded(touch: UITouch) {
        isTouching = false
    }
    
    internal func screenTouchCancelled(touch: UITouch) {
        isTouching = false
    }
    
// MARK: ScrollView Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // フロントのみ通知する
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // フロントのみ通知する
        if front.scrollView == scrollView {
            if velocity.y == 0 && !isTouching {
                delegate?.baseViewDidTouchEnd()
                scrollMovingPointY = 0
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // フロントのみ通知する
        if front.scrollView == scrollView {
            if !isTouching {
                delegate?.baseViewDidTouchEnd()
                scrollMovingPointY = 0
            }
        }
    }
    
// MARK: WebView Delegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        log.error("[error url]\(String(describing: webView.url))")
        
        let egWv: EGWebView = webView as! EGWebView
        if (error as NSError).code == NSURLErrorCancelled {
            // 連打したら-999 "(null)"になる対応
            return
        }
        
        if webView.isLoading {
            viewModel.notifyChangeProgress(object: 0)
        }
        
        if !egWv.hasLocalUrl {
            egWv.loadHtml(error: (error as NSError))
        } else {
            log.warning("already load error html")
        }
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
        
        // リクエストURLはエラーが発生した時のため保持しておく
        // エラー発生時は、リクエストしたURLを履歴に保持する
        if let latest = navigationAction.request.url?.absoluteString, latest.hasValidUrl {
            log.debug("[Request Url]: \(latest)")
            viewModel.latestRequestUrl = latest
        }
        
        saveMetaData(webView: webView as! EGWebView, completion: nil)

        // 自動スクロールを停止する
        if let autoScrollTimer = autoScrollTimer, autoScrollTimer.isValid {
            autoScrollTimer.invalidate()
            self.autoScrollTimer = nil
        }
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if ((url.absoluteString.range(of: "//itunes.apple.com/") != nil) ||
            (!url.absoluteString.hasPrefix("http://") && !url.absoluteString.hasPrefix("https://") && !url.absoluteString.hasPrefix("file://"))) {
            UIApplication.shared.openURL(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            return nil
        }
        return nil
    }
    
// MARK: KVO(Progress)
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            //estimatedProgressが変更されたときに、プログレスバーの値を変更する。
            viewModel.notifyChangeProgress(object: CGFloat(front.estimatedProgress))
        } else if keyPath == "loading" {
            // 対象のwebviewを検索する
            let otherWv: EGWebView = webViews.filter({ (w) -> Bool in
                if let w = w {
                    return context == &(w.context)
                }
                return false
            }).first!!
            
            let updateHistoryAndThumbnail = { (webView: EGWebView) in
                // ページ情報を取得
                self.saveMetaData(webView: webView, completion: { [weak self] (url) in
                    if webView.hasSavableUrl {
                        self!.isDoneAutoInput = false
                        // 有効なURLの場合は、履歴に保存する
                        self!.viewModel.saveHistory(wv: webView)
                    }
                    if webView.requestUrl != nil {
                        webView.previousUrl = webView.requestUrl
                    }
                    
                    // サムネイルを保存
                    DispatchQueue.mainSyncSafe {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { _ in
                            self!.saveThumbnail(webView: webView)
                            // くるくるを更新する
                            self!.updateNetworkActivityIndicator()
                        }
                    }
                })
            }
            if otherWv.context == front.context {
                // フロントwebviewの通知なので、プログレスを更新する
                //インジゲーターの表示、非表示をきりかえる。
                if otherWv.isLoading == true {
                    viewModel.notifyStartLoadingWebView(object: ["context": otherWv.context])
                    viewModel.notifyChangeProgress(object: CGFloat(0.1))
                    // くるくるを更新する
                    updateNetworkActivityIndicator()
                } else {
                    viewModel.notifyChangeProgress(object: 1.0)
                    // 履歴とサムネイルを更新
                    updateHistoryAndThumbnail(otherWv)
                }
            } else {
                //インジゲーターの表示、非表示をきりかえる。
                if otherWv.isLoading == true {
                    viewModel.notifyStartLoadingWebView(object: ["context": otherWv.context])
                    // くるくるを更新する
                    updateNetworkActivityIndicator()
                } else {
                    // 履歴とサムネイルを更新
                    updateHistoryAndThumbnail(otherWv)
                }

            }
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
        frame.origin.y = AppConst.headerViewHeight
    }
    
    func slideToMin() {
        frame.origin.y = DeviceConst.statusBarHeight
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
        isUserInteractionEnabled = false
        front.scrollView.isScrollEnabled = false
        front.scrollView.bounces = false
    }
    
    private func startProgressObserving(target: EGWebView) {
        log.debug("start progress observe. target: \(target.context)")

        //読み込み状態が変更されたことを取得
        target.addObserver(self, forKeyPath: "loading", options: .new, context: &(target.context))
        //プログレスが変更されたことを取得
        target.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &(target.context))
        if target.isLoading == true {
            viewModel.notifyChangeProgress(object: CGFloat(target.estimatedProgress))
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = target.isLoading
    }
    
    /// webviewを新規作成
    private func createWebView(context: String?) -> EGWebView {
        let newWv = EGWebView(id: context, isPrivate: viewModel.isPrivateMode!)
        newWv.navigationDelegate = self
        newWv.uiDelegate = self;
        newWv.scrollView.delegate = self
        front = newWv
        Util.createFolder(path: AppConst.thumbnailFolderPath(folder: newWv.context))
        addSubview(newWv)

        // プログレスバー
        startProgressObserving(target: newWv)
        
        return newWv
    }
    
    // loadWebViewはwebviewスペースがある状態で新規作成するときにコールする
    private func loadWebView() {
        let newWv = createWebView(context: viewModel.currentContext)
        webViews[viewModel.locationIndex] = newWv
        _ = newWv.load(urlStr: viewModel.requestUrl)
    }
    
    private func saveMetaData(webView: EGWebView, completion: ((_ url: String?) -> ())?) {
        if let urlStr = webView.url?.absoluteString, let title = webView.title {
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
            completion?(urlStr)
        }
    }
    
    private func saveThumbnail(webView: EGWebView) {
        // サムネイルを保存
        let img = webView.takeThumbnail()
        let pngImageData = UIImagePNGRepresentation(img!)
        let context = webView.context
        do {
            try pngImageData?.write(to: AppConst.thumbnailUrl(folder: context))
            let object: [String: Any]? = ["context": context, "url": webView.requestUrl, "title": webView.requestTitle]
            log.debug("save thumbnal. context: \(context)")
            self.viewModel.notifyEndLoadingWebView(object: object)
        } catch let error as NSError {
            log.error("failed to store thumbnail: \(error)")
        }
    }
    
    private func deleteThumbnail(webView: EGWebView) {
        log.debug("delete thumbnail. context: \(webView.context)")
        Util.deleteFolder(path: AppConst.thumbnailPath(folder: webView.context))
    }
    
// MARK: BaseViewModel Delegate
    func baseViewModelDidAutoInput() {
        if !isDisplayedKeyBoard {
            isDisplayedKeyBoard = true
            
            let forms = CommonDao.s.selectAllForm()
            for form in forms {
                if (front.url?.absoluteString.domainAndPath == form.url.domainAndPath && !isDoneAutoInput) {
                    Util.presentAlert(title: "フォーム自動入力", message: "保存済みフォームが存在します。自動入力しますか？", completion: { [weak self] _ in
                        for input in form.inputs {
                            self!.front.evaluateJavaScript("document.forms[\(input.formIndex)].elements[\(input.formInputIndex)].value=\"\(input.value)\"") { (object, error) in
                            }
                        }
                    })
                    isDoneAutoInput = true
                    break;
                }
            }
        }
    }
    
    func baseViewModelDidAddWebView() {
        if let front = front {
            // 全てのwebviewが削除された場合
            front.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        viewModel.notifyChangeProgress(object: 0)
        let newWv = createWebView(context: viewModel.currentContext)
        webViews.append(newWv)
        if viewModel.requestUrl.isEmpty {
            // 編集状態にする
            if let beginEditingWorkItem = self.beginEditingWorkItem {
                beginEditingWorkItem.cancel()
            }
            beginEditingWorkItem = DispatchWorkItem() { [weak self] _  in
                self!.viewModel.notifyBeginEditing()
                self!.beginEditingWorkItem = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: beginEditingWorkItem!)
        } else {
            _ = newWv.load(urlStr: viewModel.requestUrl)
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
        viewModel.notifyChangeProgress(object: 0)
        if let current = webViews[viewModel.locationIndex] {
            current.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &(current.context))
            front = current
            bringSubview(toFront: current)
        } else {
            loadWebView()
        }
    }
    
    func baseViewModelDidRemoveWebView(index: Int, isFrontDelete: Bool) {
        if let webView = webViews[index] {
            // サムネイルの削除
            deleteThumbnail(webView: webView)
            
            webView.removeObserver(self, forKeyPath: "loading")
            if isFrontDelete {
                webView.removeObserver(self, forKeyPath: "estimatedProgress")
                viewModel.notifyChangeProgress(object: 0)
                front = nil
            }
            webView.removeFromSuperview()
        }
        webViews.remove(at: index)
        
        // くるくるを更新
        updateNetworkActivityIndicator()

        if webViews.count == 0 {
            viewModel.notifyAddWebView()
        } else if isFrontDelete {
            // フロントの削除で、削除後にwebviewが存在する場合
            // 存在しない場合は、AddWebViewが呼ばれる
            if let current = webViews[viewModel.locationIndex] {
                current.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &(current.context))
                front = current
                bringSubview(toFront: current)
            } else {
                loadWebView()
            }
        }
    }
    func baseViewModelDidSearchWebView(text: String) {
        if text.hasValidUrl {
            let encodedText = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            _ = front.load(urlStr: encodedText)
        } else {
            // 閲覧履歴を保存する
            CommonDao.s.storeSearchHistory(searchHistory: [SearchHistoryItem(title: text, date: Date())])
            let encodedText = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            _ = front.load(urlStr: "\(AppConst.searchPath)\(encodedText)")
        }
    }
    
    func baseViewModelDidHistoryBackWebView() {
        if front.canGoBack {
            if (front.backForwardList.backItem?.url.absoluteString.hasValidUrl)! == true {
                front.goBack()
            } else {
                // 有効なURLを探す
                let backUrl: WKBackForwardListItem? = { () -> WKBackForwardListItem? in
                    for item in front.backForwardList.backList.reversed() {
                        if item.url.absoluteString.hasValidUrl {
                            return item
                        }
                    }
                    // nilが返る事は運用上あり得ない
                    log.error("webview go back error")
                    return nil
                }()
                if let item = backUrl {
                    front.go(to: item)
                }
            }
        }
    }
    
    func baseViewModelDidHistoryForwardWebView() {
        if front.canGoForward {
            if (front.backForwardList.forwardItem?.url.absoluteString.hasValidUrl)! == true {
                front.goForward()
            } else {
                // 有効なURLを探す
                let forwardUrl: WKBackForwardListItem? = { () -> WKBackForwardListItem? in
                    for item in front.backForwardList.forwardList {
                        if item.url.absoluteString.hasValidUrl {
                            return item
                        }
                    }
                    // nilが返る事は運用上あり得ない
                    log.error("webview go back error")
                    return nil
                }()
                if let item = forwardUrl {
                    front.go(to: item)
                }
            }
        }
    }
    
    func baseViewModelDidRegisterAsForm() {
        CommonDao.s.storeForm(webView: front)
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

// MARK: 自動スクロールタイマー通知
    func updateAutoScrolling(sender: Timer) {
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
