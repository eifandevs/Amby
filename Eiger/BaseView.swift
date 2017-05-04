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
    func baseViewDidTouch(touch: Bool)
}

class BaseView: UIView, WKNavigationDelegate, UIScrollViewDelegate, UIWebViewDelegate, WKUIDelegate, EGApplicationDelegate, BaseViewModelDelegate {
    
    var delegate: BaseViewDelegate?

    private var front: EGWebView!
    var webViews: [EGWebView?] = []
    private let viewModel = BaseViewModel()
    private var scrollMovingPointY: CGFloat = 0
    
    private var isTouching = false {
        didSet {
            delegate?.baseViewDidTouch(touch: isTouching)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewModel.delegate = self
        EGApplication.sharedMyApplication.egDelegate = self
        
        // webviewsに初期値を入れる
        for _ in 0...viewModel.webViewCount - 1 {
            webViews.append(nil)
        }
        
        loadWebView()
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
        let speed = scrollView.contentOffset.y - scrollMovingPointY
        if (scrollMovingPointY != 0 && !isOverScrolling || (isTouching && isOverScrolling && speed < 0) || (isTouching && isOverScrolling && speed > 0 && scrollView.contentOffset.y > 0)) {
            delegate?.baseViewDidScroll(speed: -1 * speed)
        }
        scrollMovingPointY = scrollView.contentOffset.y
    }
    
// MARK: WebView Delegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        log.error("[error url]\(String(describing: webView.url))")
        if webView.isLoading {
            viewModel.notifyChangeProgress(object: 0)
        }
        
        if !webView.hasLocalUrl {
            webView.loadHtml(error: (error as NSError))
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
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                completionHandler(.cancelAuthenticationChallenge, nil)
                webView.loadHtml(code: .UNAUTHORIZED)
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
        if let latest = navigationAction.request.url?.absoluteString, latest.hasValidUrl {
            viewModel.latestRequestUrl = latest
        }
        
        saveMetaData(webView: webView, completion: nil)

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
            viewModel.notifyChangeProgress(object: CGFloat(front.estimatedProgress))
        } else if keyPath == "loading" {
            // 対象のwebviewを検索する
            let otherWv: EGWebView = webViews.filter({ (w) -> Bool in
                if let w = w {
                    return context == &(w.context)
                }
                return false
            }).first!!
            
            if otherWv.context == front.context {
                //インジゲーターの表示、非表示をきりかえる。
                UIApplication.shared.isNetworkActivityIndicatorVisible = front.isLoading
                if front.isLoading == true {
                    viewModel.notifyStartLoadingWebView(object: ["context": otherWv.context])
                    viewModel.notifyChangeProgress(object: CGFloat(AppDataManager.shared.progressMin))
                } else {
                    viewModel.notifyChangeProgress(object: 1.0)
                    
                    // ページ情報を取得
                    saveMetaData(webView: otherWv, completion: { [weak self] (url) in
                        if self!.front.hasSavableUrl {
                            // 有効なURLの場合は、履歴に保存する
                            self!.viewModel.saveHistory(wv: self!.front)
                        }
                        if self!.front.requestUrl != nil {
                            self!.front.previousUrl = self!.front.requestUrl
                        }
                        
                        // サムネイルを保存
                        DispatchQueue.mainSyncSafe {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] _ in
                                let img = self!.front.takeThumbnail()
                                let pngImageData = UIImagePNGRepresentation(img!)
                                let context = self!.front.context
                                do {
                                    try pngImageData?.write(to: AppDataManager.shared.thumbnailPath(folder: context))
                                    let object: [String: Any]? = ["context": context, "url": otherWv.requestUrl, "title": otherWv.requestTitle]
                                    log.debug("save thumbnal. context: \(context)")
                                    self!.viewModel.notifyEndLoadingWebView(object: object)
                                } catch let error as NSError {
                                    log.error("failed to store thumbnail: \(error)")
                                }
                            }
                        }
                    })
                }
            } else {
                //インジゲーターの表示、非表示をきりかえる。
                log.debug("sub webview load end")
                if otherWv.isLoading == true {
                    viewModel.notifyStartLoadingWebView(object: ["context": otherWv.context])
                } else {
                    // ページ情報を取得
                    saveMetaData(webView: otherWv, completion: { [weak self] (url) in
                        if otherWv.hasSavableUrl {
                            // 有効なURLの場合は、履歴に保存する
                            self!.viewModel.saveHistory(wv: otherWv)
                        }
                        if otherWv.requestUrl != nil {
                            otherWv.previousUrl = otherWv.requestUrl
                        }
                        
                        // サムネイルを保存
                        DispatchQueue.mainSyncSafe {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] _ in
                                let img = otherWv.takeThumbnail()
                                let pngImageData = UIImagePNGRepresentation(img!)
                                let context = otherWv.context
                                do {
                                    try pngImageData?.write(to: AppDataManager.shared.thumbnailPath(folder: context))
                                    let object: [String: Any]? = ["context": context, "url": otherWv.requestUrl, "title": otherWv.requestTitle]
                                    self!.viewModel.notifyEndLoadingWebView(object: object)
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
        front.scrollView.setContentOffset(CGPoint(x: front.scrollView.contentOffset.x, y: front.scrollView.contentOffset.y - pt), animated: false)
    }

// MARK: Private Method
    
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
    
    // webviewを新規作成
    private func createWebView(context: String?) -> EGWebView {
        let newWv = EGWebView(id: context, pool: viewModel.processPool)
        newWv.navigationDelegate = self
        newWv.uiDelegate = self;
        newWv.scrollView.delegate = self
        
        front = newWv
        addSubview(newWv)

        // プログレスバー
        startProgressObserving(target: newWv)
        
        return newWv
    }
    
    private func loadWebView() {
        let newWv = createWebView(context: viewModel.currentContext)
        webViews[viewModel.locationIndex] = newWv
        _ = front.load(urlStr: viewModel.requestUrl)
    }
    
    private func saveMetaData(webView: WKWebView, completion: ((_ url: String?) -> ())?) {
        if let urlStr = webView.url?.absoluteString, let title = webView.title {
            if urlStr.hasValidUrl && webView.requestUrl != urlStr {
                webView.requestUrl = urlStr
                viewModel.headerFieldText = webView.requestUrl
                webView.requestTitle = title
            } else if urlStr.hasLocalUrl {
                // エラーが発生した時のheaderField更新
                viewModel.headerFieldText = viewModel.latestRequestUrl
            }
            completion?(urlStr)
        }
    }
    
// MARK: BaseViewModel Delegate

    func baseViewModelDidAddWebView() {
        front.removeObserver(self, forKeyPath: "estimatedProgress")
        viewModel.notifyChangeProgress(object: 0)
        let newWv = createWebView(context: viewModel.currentContext)
        webViews.append(newWv)
        _ = front.load(urlStr: viewModel.requestUrl)
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
        let current = webViews[viewModel.locationIndex]!
        current.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &(current.context))
        front = current
        bringSubview(toFront: current)
    }
    
    func baseViewModelDidRemoveWebView(index: Int) {
        if let webView = webViews[index] {
            webView.removeObserver(self, forKeyPath: "loading")
            webView.removeFromSuperview()
        }
        webViews.remove(at: index)
    }
    func baseViewModelDidSearchWebView(text: String) {
        let search = text.hasValidUrl ? text : "\(AppDataManager.shared.searchPath)\(text)"
        _ = front.load(urlStr: search)
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
}
