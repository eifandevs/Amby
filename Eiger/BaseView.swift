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
import SpringIndicator

class BaseView: UIView, WKNavigationDelegate, UIScrollViewDelegate, UIWebViewDelegate, WKUIDelegate, EGApplicationDelegate {
    
    private var wv: EGWebView! = nil
    private var progressBar: EGProgressBar! = nil
    private let viewModel = BaseViewModel()
    private var processPool = WKProcessPool()
    private var scrollMovingPointY: CGFloat = 0
    private var latestRequestUrl: String = ""
    
    var isTouching = Observable<Bool>(false)
    var scrollSpeed = Observable<CGFloat>(0)
    var progress = Observable<CGFloat>(0)
    var headerFieldText = Observable<String>("")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        EGApplication.sharedMyApplication.egDelegate = self
        
        // TODO: 最初に表示するWebViewを決定する
        wv = createWebView()
        
        addSubview(wv)
        
        // プログレスバー
        startProgressObserving()
        
        /* テストコード */
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 200), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("戻る(ページ)", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
                    if self!.wv.canGoBack {
                        if (self!.wv.backForwardList.backItem?.url.absoluteString.hasValidUrl)! == true {
                            self!.wv.goBack()
                        } else {
                            // 有効なURLを探す
                            let backUrl: WKBackForwardListItem? = { () -> WKBackForwardListItem? in
                                for item in self!.wv.backForwardList.backList.reversed() {
                                    if item.url.absoluteString.hasValidUrl {
                                        return item
                                    }
                                }
                                // nilが返る事は運用上あり得ない
                                log.error("webview go back error")
                                return nil
                            }()
                            if let item = backUrl {
                                self!.wv.go(to: item)
                            }
                        }
                    }
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 200), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("進む(ページ)", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
                    if self!.wv.canGoForward {
                        if (self!.wv.backForwardList.forwardItem?.url.absoluteString.hasValidUrl)! == true {
                            self!.wv.goForward()
                        } else {
                            // 有効なURLを探す
                            let forwardUrl: WKBackForwardListItem? = { () -> WKBackForwardListItem? in
                                for item in self!.wv.backForwardList.forwardList {
                                    if item.url.absoluteString.hasValidUrl {
                                        return item
                                    }
                                }
                                // nilが返る事は運用上あり得ない
                                log.error("webview go back error")
                                return nil
                            }()
                            if let item = forwardUrl {
                                self!.wv.go(to: item)
                            }
                        }
                    }
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 280), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("戻る(wv)", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    log.debug("Button tapped.")
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 280), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("進む(wv)", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    log.debug("Button tapped.")
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 360), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("リロード", for: .normal)
            // TODO: リロードは自前で管理しているURLから実施する
            _ = button.reactive.tap
                .observe { [weak self] _ in
                    if self!.wv.hasValidUrl {
                        self!.wv.reload()
                    } else {
                        _ = self!.wv.load(urlStr: self!.latestRequestUrl)
                    }
            }
            addSubview(button)
        }
        /*-----------*/
        
        // Observer登録
        _ = viewModel.requestUrl.observeNext { [weak self] value in
            // ロード
            _ = self!.wv.load(urlStr: value)
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
        log.error("[error url]\(webView.url)")
        if wv.isLoading {
            progress.value = 0
        }
        if wv.hasValidUrl {
            headerFieldText.value = latestRequestUrl
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
        let latest = (navigationAction.request.url?.absoluteString.removingPercentEncoding)!
        if latest.hasValidUrl {
            latestRequestUrl = latest
        }
        
        saveMetaData(completion: nil)
        
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
            //インジゲーターの表示、非表示をきりかえる。
            UIApplication.shared.isNetworkActivityIndicatorVisible = wv.isLoading
            if wv.isLoading == true {
                progress.value = CGFloat(AppDataManager.shared.progressMin)
            } else {
                progress.value = 1.0
                saveMetaData(completion: { [weak self] in
                    if self!.wv.hasSavableUrl {
                        self!.viewModel.saveHistory(wv: self!.wv)
                    }
                    self!.wv.previousUrl = self!.wv.requestUrl
                    log.debug("[previous url]\(self!.wv.previousUrl)")
                })
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
    
    // MARK: Private Method
    private func startProgressObserving() {
        log.debug("start progress observe")
        //読み込み状態が変更されたことを取得
        wv.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        //プログレスが変更されたことを取得
        wv.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        if wv.isLoading == true {
            progress.value = CGFloat(wv.estimatedProgress)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = wv.isLoading
    }
    
    private func createWebView() -> EGWebView {
        let wv = EGWebView(pool: processPool)
        wv.navigationDelegate = self
        wv.uiDelegate = self;
        wv.scrollView.delegate = self
        return wv
    }
    
    private func saveMetaData(completion: (() -> ())?) {
        wv.evaluateJavaScript("window.location.href") { [weak self] (object, error) in
            if let url = object {
                let urlStr = (url as! String).removingPercentEncoding!
                if urlStr.hasValidUrl && self!.wv.requestUrl != urlStr {
                    self!.wv.requestUrl = urlStr
                    self!.headerFieldText.value = self!.wv.requestUrl
                    log.debug("[request url]\(self!.wv.requestUrl)")
                }
            }
            self!.wv.evaluateJavaScript("document.title") { (object, error) in
                self!.wv.requestTitle = object as! String
                if completion != nil { completion!() }
            }
        }
    }
    
}
