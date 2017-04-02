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

class BaseView: UIView, WKNavigationDelegate, UIScrollViewDelegate, UIWebViewDelegate, WKUIDelegate, EGApplicationDelegate {
    
    private var wv: EGWebView! {
        get {
            return webViews[viewModel.getLocationIndex()] as! EGWebView
        }
    }
    let webViews = MutableObservableArray([])
    private let viewModel = BaseViewModel()
    private var scrollMovingPointY: CGFloat = 0
    
    var isTouching = Observable<Bool>(false)
    var scrollSpeed = Observable<CGFloat>(0)
    var progress = Observable<CGFloat>(0)
    var headerFieldText = Observable<String>("")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        EGApplication.sharedMyApplication.egDelegate = self
        
        // TODO: 最初に表示するWebViewを決定する
        let wv = createWebView(context: viewModel.currentContext)
        
        addSubview(wv)
        
        // プログレスバー
        startProgressObserving()
        
        // Observer登録
        _ = viewModel.requestUrl.observeNext { [weak self] value in
            // ロード
            _ = self!.wv.load(urlStr: value)
        }
        
        _ = webViews.observeNext { [weak self] e in
            if e.change == .inserts([self!.webViews.count - 1]) {
                self!.viewModel.goForwardLocationIndex()
            }
        }
    }
    
    deinit {
        wv.removeObserver(self, forKeyPath: "estimatedProgress")
        wv.removeObserver(self, forKeyPath: "loading")
    }
    
    override func layoutSubviews() {
        wv.frame = CGRect(origin: CGPoint.zero, size: frame.size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: EGApplication Delegate
    
    internal func screenTouchBegan(touch: UITouch) {
        isTouching.value = true
    }
    
    internal func screenTouchMoved(touch: UITouch) {
    }
    
    internal func screenTouchEnded(touch: UITouch) {
        isTouching.value = false
        scrollMovingPointY = 0
    }
    
    internal func screenTouchCancelled(touch: UITouch) {
        isTouching.value = false
        scrollMovingPointY = 0
    }
    
// MARK: ScrollView Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isOverScrolling = (scrollView.contentOffset.y <= 0) || (scrollView.contentOffset.y >= scrollView.contentSize.height - frame.size.height)
        let speed = scrollView.contentOffset.y - scrollMovingPointY
        if (scrollMovingPointY != 0 && !isOverScrolling || (isTouching.value && isOverScrolling && speed < 0)) {
            scrollSpeed.value =  -1 * speed
        }
        scrollMovingPointY = scrollView.contentOffset.y
    }
    
// MARK: WebView Delegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        log.error("[error url]\(String(describing: webView.url))")
        if wv.isLoading {
            progress.value = 0
        }
        
        if !wv.hasLocalUrl {
            wv.loadHtml(error: (error as NSError))
        } else {
            log.warning("already load error html")
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] action in
                completionHandler(.cancelAuthenticationChallenge, nil)
                self!.wv.loadHtml(code: .UNAUTHORIZED)
            }))
            alertController.addAction(UIAlertAction(title: "Log In", style: .default, handler: { action in
                let credential = URLCredential(user: usernameTextField.text!, password: passwordTextField.text!, persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, credential)
            }))
            Util.shared.foregroundViewController().present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // リクエストURLはエラーが発生した時のため保持しておく
        // エラー発生時は、リクエストしたURLを履歴に保持する
        let latest = (navigationAction.request.url?.absoluteString)!

        if latest.hasValidUrl {
            viewModel.latestRequestUrl = latest
            saveMetaData(completion: nil)
        }
        
        if latest.hasLocalUrl {
            // エラーが発生した時のheaderField更新
            headerFieldText.value = viewModel.latestRequestUrl
        }

        // TODO: 自動スクロール実装
        //        if autoScrollTimer?.valid == true {
        //            autoScrollTimer?.invalidate()
        //            autoScrollTimer = nil
        //        }
        
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
            progress.value = CGFloat(wv.estimatedProgress)
        } else if keyPath == "loading" {
            if context == &(wv.context) {
                //インジゲーターの表示、非表示をきりかえる。
                UIApplication.shared.isNetworkActivityIndicatorVisible = wv.isLoading
                if wv.isLoading == true {
                    viewModel.postNotification(name: .baseViewDidStartLoading, object: nil)
                    progress.value = CGFloat(AppDataManager.shared.progressMin)
                } else {
                    progress.value = 1.0
                    
                    // ページ情報を取得
                    saveMetaData(completion: { [weak self] (url) in
                        if self!.wv.hasSavableUrl {
                            // 有効なURLの場合は、履歴に保存する
                            self!.viewModel.saveHistory(wv: self!.wv)
                        }
                        if self!.wv.requestUrl != nil {
                            self!.wv.previousUrl = self!.wv.requestUrl
                            log.debug("[previous url]\(self!.wv.previousUrl)")
                        }
                        
                        // サムネイルを保存
                        DispatchQueue.mainSyncSafe {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] _ in
                                let img = self!.wv.takeThumbnail()
                                let pngImageData = UIImagePNGRepresentation(img!)
                                let context = self!.wv.context
                                do {
                                    try pngImageData?.write(to: AppDataManager.shared.thumbnailPath(folder: context))
                                    let object = url == nil ? ["context": context] : ["context": context, "url": (url! as String)]
                                    self!.viewModel.postNotification(name: .baseViewDidEndLoading, object: object)
                                    log.debug("save thumbnal success. context: \(context)")
                                } catch let error as NSError {
                                    log.error("failed to store thumbnail: \(error)")
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
// MARK: Public Method
    
    func scroll(pt: CGFloat) {
        wv.scrollView.setContentOffset(CGPoint(x: wv.scrollView.contentOffset.x, y: wv.scrollView.contentOffset.y - pt), animated: false)
    }
    
    func stopProgressObserving() {
        log.debug("stop progress observe")
        if let _webView = wv {
            _webView.removeObserver(self, forKeyPath: "estimatedProgress")
            _webView.removeObserver(self, forKeyPath: "loading")
        }
    }
    
    func storeHistory() {
        viewModel.storeHistory()
    }
    
// MARK: Public Method(WebView Action)
    
    func doSearch(text: String) {
        let search = text.hasValidUrl ? text : "\(AppDataManager.shared.searchPath)\(text)"
        _ = wv.load(urlStr: search)
    }
    
    func doHistoryBack() {
        log.debug("[WebView Action]: history back")
        if wv.canGoBack {
            if (wv.backForwardList.backItem?.url.absoluteString.hasValidUrl)! == true {
                wv.goBack()
            } else {
                // 有効なURLを探す
                let backUrl: WKBackForwardListItem? = { () -> WKBackForwardListItem? in
                    for item in wv.backForwardList.backList.reversed() {
                        if item.url.absoluteString.hasValidUrl {
                            return item
                        }
                    }
                    // nilが返る事は運用上あり得ない
                    log.error("webview go back error")
                    return nil
                }()
                if let item = backUrl {
                    wv.go(to: item)
                }
            }
        }
    }
    
    func doHistoryForward() {
        log.debug("[WebView Action]: history forward")
        if wv.canGoForward {
            if (wv.backForwardList.forwardItem?.url.absoluteString.hasValidUrl)! == true {
                wv.goForward()
            } else {
                // 有効なURLを探す
                let forwardUrl: WKBackForwardListItem? = { () -> WKBackForwardListItem? in
                    for item in wv.backForwardList.forwardList {
                        if item.url.absoluteString.hasValidUrl {
                            return item
                        }
                    }
                    // nilが返る事は運用上あり得ない
                    log.error("webview go back error")
                    return nil
                }()
                if let item = forwardUrl {
                    wv.go(to: item)
                }
            }
        }
    }

    func doWebViewBack() {
        log.debug("[WebView Action]: webview back")
    }
    
    func doWebViewForward() {
        log.debug("[WebView Action]: webview forward")
    }
    
    // 新しいWebViewを配列の最後尾に作成する
    // 作成と同時にそのWebViewに移動する
    func doWebViewAdd() {
        log.debug("[WebView Action]: webview add")
        wv.removeObserver(self, forKeyPath: "estimatedProgress")
        progress.value = 0
        
        let _ = createWebView(context: nil)
        
        // プログレスバー
        startProgressObserving()
    }

    func doWebViewDelete() {
        log.debug("[WebView Action]: webview delete")
    }
    
    func doWebViewReload() {
        log.debug("[WebView Action]: webview reload")
        if wv.hasValidUrl {
            wv.reload()
        } else {
            let reloadUrl = headerFieldText.value.isEmpty ? viewModel.defaultUrl : headerFieldText.value
            _ = wv.load(urlStr: reloadUrl)
        }
    }

// MARK: Private Method
    
    private func startProgressObserving() {
        log.debug("start progress observe")

        //読み込み状態が変更されたことを取得
        wv.addObserver(self, forKeyPath: "loading", options: .new, context: &(wv.context))
        //プログレスが変更されたことを取得
        wv.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        if wv.isLoading == true {
            progress.value = CGFloat(wv.estimatedProgress)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = wv.isLoading
    }
    
    // 初回起動時に表示するwebviewを作成
    private func createWebView(context: String?) -> EGWebView {
        let wv = EGWebView(id: context, pool: viewModel.processPool)
        wv.navigationDelegate = self
        wv.uiDelegate = self;
        wv.scrollView.delegate = self
        
        viewModel.postNotification(name: .baseViewDidAddWebView, object: nil)
        
        addSubview(wv)

        webViews.append(wv)

        return wv
    }
    
    private func saveMetaData(completion: ((_ url: String?) -> ())?) {
        wv.evaluateJavaScript("window.location.href") { [weak self] (object, error) in
            if let url = object {
                let urlStr = url as! String
                if urlStr.hasValidUrl && self!.wv.requestUrl != urlStr {
                    self!.wv.requestUrl = urlStr
                    self!.headerFieldText.value = self!.wv.requestUrl
                    log.debug("[request url]\(self!.wv.requestUrl)")
                    self!.wv.evaluateJavaScript("document.title") { (object, error) in
                        self!.wv.requestTitle = object as! String
                        completion?(urlStr)
                        return
                    }
                }
            }
            completion?(nil)
        }
    }
    
}
