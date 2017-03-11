//
//  EGWebView.swift
//  Eiger
//
//  Created by temma on 2017/02/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import WebKit

class EGWebView: WKWebView {
    enum NETWORK_ERROR {
        case DNS_NOT_FOUND
        case OFFLINE
        case TIMEOUT
        case INVALID_URL
        case UNAUTHORIZED
    }
    
    var errorUrl: URL? = nil // 読み込みに失敗した最新のURL
    var previousUrl: URL? = nil // リロードしたページを履歴に登録しないために、前回URLを保持しておく
    var hasSavableUrl: Bool {
        get {
            return ((previousUrl != nil) &&
                (url?.absoluteString != "http://about:blank") &&
                (previousUrl?.absoluteString != url?.absoluteString))
        }
    }
    
    var hasValidUrl: Bool {
        get {
            if requestUrl != nil {
                return requestUrl.absoluteString.hasValidUrl
            }
            return false
        }
    }
    
    init(pool: WKProcessPool) {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = pool
        // Cookie, Cache, その他Webデータを端末内に残す
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.allowsPictureInPictureMediaPlayback = true
        super.init(frame: CGRect.zero, configuration: configuration)
        isOpaque = true
        allowsLinkPreview = true
    }
    
    func load(urlStr: String) -> Bool {
        requestUrl = URL(string: urlStr)
        if  urlStr.hasValidUrl {
            let encodedURL = urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            guard let url = URL(string: encodedURL!) else {
                log.error("invalud url load")
                return false
            }
            super.load(URLRequest(url: url))
            return true
        } else if urlStr.hasPrefix("file://") {
            loadHtml(code: urlToCode(urlStr: urlStr))
        }
        loadHtml(code: NETWORK_ERROR.INVALID_URL)
        return false
    }
    
    private func urlToCode(urlStr: String) -> NETWORK_ERROR {
        switch (urlStr as NSString).lastPathComponent {
        case "timeout.html":
            return NETWORK_ERROR.TIMEOUT
        case "dns.html":
            return NETWORK_ERROR.DNS_NOT_FOUND
        case "offline.html":
            return NETWORK_ERROR.OFFLINE
        case "authorize.html":
            return NETWORK_ERROR.UNAUTHORIZED
        default:
            return NETWORK_ERROR.INVALID_URL
        }
    }
    
    func loadHtml(code: NETWORK_ERROR) {
        let path: String = { _ in
            if code == NETWORK_ERROR.TIMEOUT { return Bundle.main.path(forResource: "timeout", ofType: "html")! }
            if code == NETWORK_ERROR.DNS_NOT_FOUND { return Bundle.main.path(forResource: "dns", ofType: "html")! }
            if code == NETWORK_ERROR.OFFLINE { return Bundle.main.path(forResource: "offline", ofType: "html")! }
            if code == NETWORK_ERROR.UNAUTHORIZED { return Bundle.main.path(forResource: "authorize", ofType: "html")! }
            return Bundle.main.path(forResource: "invalid", ofType: "html")!
        }()
        if hasValidUrl || requestUrl.absoluteString.hasValidUrl {
            errorUrl = requestUrl // 読み込みに失敗したURLは保存しておく
        }
        super.loadFileURL(URL(fileURLWithPath: path), allowingReadAccessTo: URL(fileURLWithPath: path))
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
