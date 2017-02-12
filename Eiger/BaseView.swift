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
    
    private var webView: EGWebView! = nil
    private var progressBar: EGProgressBar! = nil
    private let viewModel = BaseViewModel()
    private var processPool = WKProcessPool()

    init() {
        super.init(frame: CGRect.zero)
        EGApplication.sharedMyApplication.egDelegate = self
        
        // TODO: 最初に表示するWebViewを決定する
        webView = createWebView()
        addSubview(webView)
        
        
        /* テストコード */
//        do {
//            let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 50), size: CGSize(width: 50, height: 50)))
//            button.backgroundColor = UIColor.red
//            _ = button.reactive.tap
//                .observe { _ in
//                    print("Button tapped.")
//            }
//            addSubview(button)
//        }
//        
//        do {
//            let button = UIButton(frame: CGRect(origin: CGPoint(x: 100, y: 50), size: CGSize(width: 50, height: 50)))
//            button.backgroundColor = UIColor.red
//            _ = button.reactive.tap
//                .observe { _ in
//                    print("Button tapped.")
//            }
//            addSubview(button)
//        }
        /*-----------*/
        
        // プログレスバー
        startProgressObserving()

        // ロード
        _ = webView.load(urlStr: viewModel.defaultUrl)
    }
    
    override func layoutSubviews() {
        webView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
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
    }
    
// MARK: KVO(Progress)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
            progressBar.setProgress(CGFloat(webView.estimatedProgress), animated: true)
        } else if keyPath == "loading" {
            //インジゲーターの表示、非表示をきりかえる。
            UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
            if webView.isLoading == true {
                progressBar.setProgress(0.1, animated: true)
            } else {
                viewModel.saveHistory(webView: webView)
                progressBar.setProgress(0.0, animated: false)
            }
        }
    }
    
// MARK: Public Method
    func stopProgressObserving() {
        log.debug("stop progress observe")
        if let _webView = webView {
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
    
// MARK: Private Method
    private func startProgressObserving() {
        log.debug("start progress observe")
        progressBar = EGProgressBar()
        
        //読み込み状態が変更されたことを取得
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        //プログレスが変更されたことを取得
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        if webView.isLoading == true {
            progressBar.setProgress(CGFloat(webView.estimatedProgress), animated: true)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
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
