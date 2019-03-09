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

    let resourceUtil = ResourceUtil()

    init(id: String?) {
        if let id = id, !id.isEmpty {
            // コンテキストを復元
            context = id
        }
        super.init(frame: CGRect.zero, configuration: WebCacheUseCase.s.cacheConfiguration())
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

    func highlight(word: String) {
        let scriptPath = resourceUtil.highlightScript
        do {
            let script = try String(contentsOf: scriptPath, encoding: .utf8)
            evaluateJavaScript(script) { (_: Any?, error: Error?) in
                if error != nil {
                    log.error("js setup error: \(error!)")
                }
            }
            evaluateJavaScript("MyApp_HighlightAllOccurencesOfString('\(word)')") { (result: Any?, error: Error?) in
                if let error = error {
                    log.error("js grep error: \(error.localizedDescription)")
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.GREP_ERROR, isSuccess: false)
                } else {
                    let num = result as? NSNumber ?? 0
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.GREP_SUCCESS(num), isSuccess: true)
                }
            }
        } catch let error as NSError {
            log.error("failed to get script. error: \(error.localizedDescription)")
        }
    }

//    - (NSInteger)highlightAllOccurencesOfString:(NSString*)str
//    {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
//    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [self stringByEvaluatingJavaScriptFromString:jsCode];
//
//    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@')",str];
//    [self stringByEvaluatingJavaScriptFromString:startSearch];
//
//    NSString *result = [self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount"];
//    return [result integerValue];
//    }
//
//    - (void)removeAllHighlights
//    {
//    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
//    }

    func takeThumbnail() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
}
