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
    private var isTouching = false
    private var scrollMovingPointY: CGFloat = 0
    
    var scrollSpeed = Observable<CGFloat>(0)
    
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
                    self!.wv.goBack()
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 200), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("進む(ページ)", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
                    self!.wv.goForward()
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
            _ = button.reactive.tap
                .observe { [weak self] _ in
                    self!.wv.reload()
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
        progressBar.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 2.1)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: EGApplication Delegate
    internal func screenTouchBegan(touch: UITouch) {
        isTouching = true
    }
    
    internal func screenTouchMoved(touch: UITouch) {
    }
    
    internal func screenTouchEnded(touch: UITouch) {
        isTouching = false
        scrollMovingPointY = 0
    }
    
    internal func screenTouchCancelled(touch: UITouch) {
        isTouching = false
        scrollMovingPointY = 0
    }
    
    // MARK: ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isOverScrolling = (scrollView.contentOffset.y <= 0) || (scrollView.contentOffset.y >= scrollView.contentSize.height - frame.size.height)
        if (scrollMovingPointY != 0 && !isOverScrolling || (isTouching && isOverScrolling)) {
            scrollSpeed.value =  -1 * (scrollView.contentOffset.y - scrollMovingPointY)
        }
        scrollMovingPointY = scrollView.contentOffset.y
    }
    
    // MARK: WebView Delegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressBar.initializeProgress()
        wv.loadHtml(error: (error as NSError))
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
        log.debug("[request url]\(navigationAction.request.url)")
        
        // リクエストURLはエラーが発生した時のため保持しておく
        // エラー発生時は、リクエストしたURLを履歴に保持する
        webView.requestUrl = navigationAction.request.url
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
            //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
            progressBar.setProgress(CGFloat(wv.estimatedProgress))
        } else if keyPath == "loading" {
            //インジゲーターの表示、非表示をきりかえる。
            UIApplication.shared.isNetworkActivityIndicatorVisible = wv.isLoading
            if wv.isLoading == true {
                progressBar.isFinished = false
                progressBar.setProgress(0.1)
            } else {
                progressBar.setProgress(1.0)
                if wv.title != nil && wv.url != nil {
                    if wv.hasSavableUrl {
                        viewModel.saveHistory(wv: wv)
                    }
                    wv.previousUrl = (wv.hasValidUrl || wv.errorUrl == nil) ? wv.url : wv.errorUrl
                    log.debug("set previous url. url: \(wv.previousUrl)")
                }
            }
        }
    }
    
    // MARK: Public Method
    func stopProgressObserving() {
        log.debug("stop progress observe")
        if let _webView = wv {
            _webView.removeObserver(self, forKeyPath: "estimatedProgress")
            _webView.removeObserver(self, forKeyPath: "loading")
        }
        if let _progressBar = progressBar {
            _progressBar.removeProgress()
            progressBar = nil
        }
    }
    
    func initializeProgress() {
        if let _progressBar = progressBar {
            _progressBar.initializeProgress()
        }
    }
    
    func storeHistory() {
        viewModel.storeHistory()
    }
    
    func expand() {
        UIView.animate(withDuration: 0.1, animations: {
            //            self.frame.size.height = DeviceDataManager.shared.statusBarHeight * 2.5
            self.frame.origin.y -= DeviceDataManager.shared.statusBarHeight * 1.5
        })
    }
    
    func reduction() {
        UIView.animate(withDuration: 0.1, animations: {
            //            self.frame.size.height = DeviceDataManager.shared.statusBarHeight
            self.frame.origin.y += DeviceDataManager.shared.statusBarHeight * 1.5
        })
    }
    
    // MARK: Private Method
    private func startProgressObserving() {
        log.debug("start progress observe")
        progressBar = EGProgressBar()
        
        //読み込み状態が変更されたことを取得
        wv.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        //プログレスが変更されたことを取得
        wv.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        if wv.isLoading == true {
            progressBar.setProgress(CGFloat(wv.estimatedProgress))
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = wv.isLoading
        
        addSubview(progressBar)
    }
    
    private func createWebView() -> EGWebView {
        let wv = EGWebView(pool: processPool)
        wv.navigationDelegate = self
        wv.uiDelegate = self;
        wv.scrollView.delegate = self
        return wv
    }
    
}
