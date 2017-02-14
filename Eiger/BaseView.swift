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
    
    private var wv: EGWebView! = nil
    private var progressBar: EGProgressBar! = nil
    private let viewModel = BaseViewModel()
    private var processPool = WKProcessPool()

    init() {
        super.init(frame: CGRect.zero)
        EGApplication.sharedMyApplication.egDelegate = self
        
        // TODO: 最初に表示するWebViewを決定する
        wv = createWebView()
        
        addSubview(wv)
        
        // プログレスバー
        startProgressObserving()
        
        
        /* テストコード */
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 200), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("戻る(ページ)", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    log.debug("Button tapped.")
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 280), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("戻る(wv)", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    log.debug("Button tapped.")
            }
            addSubview(button)
        }

        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 200, y: 200), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("進む(ページ)", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    log.debug("Button tapped.")
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 200, y: 280), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("進む(wv)", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    log.debug("Button tapped.")
            }
            addSubview(button)
        }
        /*-----------*/

        // ロード
        _ = wv.load(urlStr: viewModel.defaultUrl)
    }
    
    deinit {
        wv.removeObserver(self, forKeyPath: "estimatedProgress")
        wv.removeObserver(self, forKeyPath: "loading")
    }
    
    override func layoutSubviews() {
        wv.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        progressBar.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 3)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: EGApplication Delegate
    internal func screenTouchBegan(touch: UITouch) {
    }
    
    internal func screenTouchMoved(touch: UITouch) {
    }
    
    internal func screenTouchEnded(touch: UITouch) {
    }
    
    internal func screenTouchCancelled(touch: UITouch) {
    }
    
// MARK: WebView Delegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressBar.setProgress(0.0, animated: false)
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
            progressBar.setProgress(CGFloat(wv.estimatedProgress), animated: true)
        } else if keyPath == "loading" {
            //インジゲーターの表示、非表示をきりかえる。
            UIApplication.shared.isNetworkActivityIndicatorVisible = wv.isLoading
            if wv.isLoading == true {
                progressBar.setProgress(0.1, animated: true)
            } else {
                viewModel.saveCommonHistory(webView: wv)
                progressBar.setProgress(1.0, animated: false)
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
        viewModel.storeCommonHistory()
        viewModel.storeEachHistory()
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
            progressBar.setProgress(CGFloat(wv.estimatedProgress), animated: true)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = wv.isLoading
        // プルダウンリフレッシュ
        //        if refreshControl != nil {
        //            refreshControl.removeFromSuperview()
        //            refreshControl = nil
        //        }
        //        refreshControl = UIRefreshControl()
        //        refreshControl.attributedTitle = NSAttributedString(string: " ")
        //        refreshControl.addTarget(self, action: #selector(BaseViewController.pullToRefresh), forControlEvents:.ValueChanged)
        //        webView.scrollView.addSubview(refreshControl)
        
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
