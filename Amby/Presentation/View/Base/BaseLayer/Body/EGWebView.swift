//
//  EGWebView.swift
//  Eiger
//
//  Created by temma on 2017/02/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Entity
import Foundation
import Hydra
import Model
import RxCocoa
import RxSwift
import UIKit
import WebKit

class EGWebView: WKWebView {
    enum NetWorkError {
        case dnsNotFound
        case offline
        case timeout
        case invalidUrl
        case unauthorized
    }

    var context = "" // 監視ID

    // スワイプ中かどうか
    var isSwiping: Bool = false

    /// observing estimatedprogress flag
    var isObservingEstimagedProgress = false

    /// observing title flag
    var isObservingTitle = false

    /// observing url flag
    var isObservingUrl = false

    /// observing cangoback
    var isObservingCanGoBack = false

    /// observing cangoforward
    var isObservingCanGoForward = false

    let resourceUtil = ResourceUtil()

    init(id: String?, configuration: WKWebViewConfiguration) {
        if let id = id, !id.isEmpty {
            // コンテキストを復元
            context = id
        }
        super.init(frame: CGRect.zero, configuration: configuration)
        isOpaque = true
        allowsLinkPreview = true

        let panGesture = UIPanGestureRecognizer()

        // Panジェスチャー
        panGesture.rx.event
            .subscribe { [weak self] sender in
                // ログが大量に出るので、コメントアウト
//                log.eventIn(chain: "rx_pan")
                guard let `self` = self else { return }
                if let sender = sender.element {
                    if sender.state == .began || sender.state == .changed {
                        self.isSwiping = true
                    } else {
                        self.isSwiping = false
                    }
                }
//                log.eventOut(chain: "rx_pan")
            }
            .disposed(by: rx.disposeBag)

        addGestureRecognizer(panGesture)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
    }

    /// start observe 'EstimatedProgress'
    func observeEstimatedProgress(observer: NSObject) {
        if !isObservingEstimagedProgress {
            addObserver(observer, forKeyPath: "estimatedProgress", options: .new, context: &context)
            isObservingEstimagedProgress = true
        }
    }

    /// remove observe 'EstimatedProgress'
    func removeObserverEstimatedProgress(observer: NSObject) {
        if isObservingEstimagedProgress {
            removeObserver(observer, forKeyPath: "estimatedProgress")
            isObservingEstimagedProgress = false
        }
    }

    /// start observe 'title'
    func observeTitle(observer: NSObject) {
        if !isObservingTitle {
            addObserver(observer, forKeyPath: "title", options: .new, context: &context)
            isObservingTitle = true
        }
    }

    /// remove observe 'title'
    func removeObserverTitle(observer: NSObject) {
        if isObservingTitle {
            removeObserver(observer, forKeyPath: "title")
            isObservingTitle = false
        }
    }

    /// start observe 'url'
    func observeUrl(observer: NSObject) {
        if !isObservingUrl {
            addObserver(observer, forKeyPath: "URL", options: .new, context: &context)
            isObservingUrl = true
        }
    }

    /// remove observe 'url'
    func removeObserverUrl(observer: NSObject) {
        if isObservingUrl {
            removeObserver(observer, forKeyPath: "URL")
            isObservingUrl = false
        }
    }

    /// start observe 'canGoBack'
    func observeCanGoBack(observer: NSObject) {
        if !isObservingCanGoBack {
            addObserver(observer, forKeyPath: "canGoBack", options: .new, context: &context)
            isObservingCanGoBack = true
        }
    }

    /// remove observe 'canGoBack'
    func removeObserverCanGoBack(observer: NSObject) {
        if isObservingCanGoBack {
            removeObserver(observer, forKeyPath: "canGoBack")
            isObservingCanGoBack = false
        }
    }

    /// start observe 'canGoForward'
    func observeCanGoForward(observer: NSObject) {
        if !isObservingCanGoForward {
            addObserver(observer, forKeyPath: "canGoForward", options: .new, context: &context)
            isObservingCanGoForward = true
        }
    }

    /// remove observe 'canGoBack'
    func removeObserverCanGoForward(observer: NSObject) {
        if isObservingCanGoForward {
            removeObserver(observer, forKeyPath: "canGoForward")
            isObservingCanGoForward = false
        }
    }

    // 同期実行
    func evaluateSync(script: String) -> Any? {
        var finished = false
        var ret: Any?

        evaluateJavaScript(script) { result, error in
            if let error = error {
                log.error("evaluate error. error: \(String(describing: error.localizedDescription))")
            }
            ret = result
            finished = true
        }

        while !finished {
            RunLoop.current.run(mode: RunLoopMode(rawValue: "NSDefaultRunLoopMode"), before: NSDate.distantFuture)
        }

        return ret
    }

    // promise
    func evaluate(script: String) -> Promise<Any?> {
        return Promise<Any?>(in: .background, token: nil) { resolve, reject, _ in
            self.evaluateJavaScript(script) { result, error in
                if let error = error {
                    reject(error)
                } else {
                    resolve(result)
                }
            }
        }
    }

    var isValidUrl: Bool {
        if let url = url {
            return url.absoluteString.isValidUrl
        }
        return false
    }

    var isLocalUrl: Bool {
        if let url = url {
            return url.absoluteString.isLocalUrl
        }
        return false
    }

    @discardableResult
    func load(urlStr: String) -> Bool {
        if urlStr.isValidUrl {
            guard let url = URL(string: urlStr.encodeUrl()!) else {
                log.error("invalid url load. url: \(urlStr)")
                return false
            }
            load(URLRequest(url: url))
            return true
        }
        loadHtml(code: NetWorkError.invalidUrl)
        return false
    }

    func loadHtml(code: NetWorkError) {
        let path: String = { () -> String in
            if code == NetWorkError.timeout { return resourceUtil.timeoutHtml }
            if code == NetWorkError.dnsNotFound { return resourceUtil.dnsHtml }
            if code == NetWorkError.offline { return resourceUtil.offlineHtml }
            if code == NetWorkError.unauthorized { return resourceUtil.authorizeHtml }
            return resourceUtil.invalidHtml
        }()

        do {
            // ローカルページはヒストリースタックに入れたくないので、文字列として読み込む
            let htmlStr = try String(contentsOfFile: path, encoding: .utf8)
            loadHTMLString(htmlStr, baseURL: nil)
        } catch {
            log.error("html to string error")
        }
    }

    func loadHtml(error: NSError) {
        let errorType = { () -> EGWebView.NetWorkError in
            log.error("webview load error. code: \(error.code)")
            switch error.code {
            case NSURLErrorCannotFindHost:
                return NetWorkError.dnsNotFound
            case NSURLErrorTimedOut:
                return NetWorkError.timeout
            case NSURLErrorNotConnectedToInternet:
                return NetWorkError.offline
            default:
                return NetWorkError.invalidUrl
            }
        }()
        loadHtml(code: errorType)
    }

    func parseHtml(completion: @escaping ((String, Error?) -> Void)) {
        evaluateJavaScript("document.body.innerHTML") { (result: Any?, error: Error?) in
            if let error = error {
                log.error("js parse html error: \(error.localizedDescription)")
                completion("", error)
            } else {
                if let html = result as? String {
                    completion(html, nil)
                } else {
                    completion("", NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        }
    }

    func scrollUp() {
        evaluateJavaScript("window.scrollTo(0, 0)") { _, _ in
        }
    }

    func scrollIntoViewWithIndex(index: Int, completion: @escaping (Error?) -> Void) {
        let scriptPath = resourceUtil.highlightScript
        do {
            let script = try String(contentsOf: scriptPath, encoding: .utf8)
            evaluateJavaScript(script) { (_: Any?, error: Error?) in
                if let error = error {
                    log.error("js setup error: \(error)")
                    completion(error)
                }
            }
            evaluateJavaScript("scrollIntoViewWithIndex(\(index))") { (_: Any?, error: Error?) in
                if let error = error {
                    log.error("js scrollIntoView error: \(error.localizedDescription)")
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        } catch let error as NSError {
            log.error("failed to get script. error: \(error.localizedDescription)")
            completion(error)
        }
    }

    func highlight(word: String, completion: @escaping ((Int, Error?) -> Void)) {
        let scriptPath = resourceUtil.highlightScript
        do {
            let script = try String(contentsOf: scriptPath, encoding: .utf8)
            evaluateJavaScript(script) { (_: Any?, error: Error?) in
                if let error = error {
                    log.error("js setup error: \(error)")
                    completion(0, error)
                }
            }
            evaluateJavaScript("highlightAllOccurencesOfString('\(word)')") { (result: Any?, error: Error?) in
                if let error = error {
                    log.error("js grep error: \(error.localizedDescription)")
                    completion(0, error)
                } else {
                    if let num = result as? NSNumber {
                        completion(Int(truncating: num), nil)
                    } else {
                        completion(0, NSError(domain: "", code: 0, userInfo: nil))
                    }
                }
            }
        } catch let error as NSError {
            log.error("failed to get script. error: \(error.localizedDescription)")
            completion(0, error)
        }
    }

    func takeThumbnail() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
}
