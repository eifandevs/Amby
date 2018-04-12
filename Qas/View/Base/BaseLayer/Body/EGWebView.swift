//
//  EGWebView.swift
//  Eiger
//
//  Created by temma on 2017/02/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit
import WebKit

class EGWebView: WKWebView {
    enum NETWORK_ERROR {
        case DNS_NOT_FOUND
        case OFFLINE
        case TIMEOUT
        case INVALID_URL
        case UNAUTHORIZED
    }

    var context = "" // 監視ID

    // 最新のリクエストURLを常に保持しておく
    // 履歴保存時やリロード時に使用する
    var previousUrl: String!

    // 最新のリクエストURL
    // 不正なリクエストは入らない
    var requestUrl: String!
    var requestTitle: String!

    // スワイプ中かどうか
    var isSwiping: Bool = false

    /// オペレーション
    var operation: PageHistory.Operation = .normal

    // TODO: submit検知
//    var form: Form?

    init(id: String?) {
        if let id = id, !id.isEmpty {
            // コンテキストを復元
            context = id
        }
        super.init(frame: CGRect.zero, configuration: CacheHelper.cacheConfiguration())
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

    func evaluate(script: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var finished = false

        evaluateJavaScript(script) { result, error in
            if error == nil {
                if result != nil {
                    completion(result as AnyObject?, nil)
                }
            } else {
                completion(nil, error as NSError?)
            }
            finished = true
        }

        while !finished {
            RunLoop.current.run(mode: RunLoopMode(rawValue: "NSDefaultRunLoopMode"), before: NSDate.distantFuture)
        }
    }

    var hasSavableUrl: Bool {
        return previousUrl != requestUrl && requestUrl.isValidUrl
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
            let encodedUrlStr = urlStr.contains("%") ? urlStr : urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            guard let url = URL(string: encodedUrlStr) else {
                log.error("invalud url load. url: \(encodedUrlStr)")
                return false
            }
            load(URLRequest(url: url))
            return true
        }
        loadHtml(code: NETWORK_ERROR.INVALID_URL)
        return false
    }

    func loadHtml(code: NETWORK_ERROR) {
        let path: String = { () -> String in
            if code == NETWORK_ERROR.TIMEOUT { return Bundle.main.path(forResource: "timeout", ofType: "html")! }
            if code == NETWORK_ERROR.DNS_NOT_FOUND { return Bundle.main.path(forResource: "dns", ofType: "html")! }
            if code == NETWORK_ERROR.OFFLINE { return Bundle.main.path(forResource: "offline", ofType: "html")! }
            if code == NETWORK_ERROR.UNAUTHORIZED { return Bundle.main.path(forResource: "authorize", ofType: "html")! }
            return Bundle.main.path(forResource: "invalid", ofType: "html")!
        }()
        loadFileURL(URL(fileURLWithPath: path), allowingReadAccessTo: URL(fileURLWithPath: path))
    }

    func loadHtml(error: NSError) {
        let errorType = { () -> EGWebView.NETWORK_ERROR in
            log.error("webview load error. code: \(error.code)")
            switch error.code {
            case NSURLErrorCannotFindHost:
                return NETWORK_ERROR.DNS_NOT_FOUND
            case NSURLErrorTimedOut:
                return NETWORK_ERROR.TIMEOUT
            case NSURLErrorNotConnectedToInternet:
                return NETWORK_ERROR.OFFLINE
            default:
                return NETWORK_ERROR.INVALID_URL
            }
        }()
        loadHtml(code: errorType)
    }

    func takeThumbnail() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
}
