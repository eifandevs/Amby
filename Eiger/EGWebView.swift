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
    
    var originalUrl: URL? = nil // リダイレクト前の最初のリクエスト
    var previousUrl: URL? = nil // リロードしたページを履歴に登録しないためのフラグ
    var isHistoryRequest: Bool = false // ページを戻る(進む)のリクエストかどうか
    var isValid: Bool {
        get {
            return ((title != nil) &&
                (url != nil) &&
                (previousUrl?.absoluteString != url?.absoluteString))
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
        if (validUrl(urlStr: urlStr)) {

            let encodedURL = urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            guard let url = URL(string: encodedURL!) else {
                log.error("invalud url load")
                return false
            }
            super.load(URLRequest(url: url))
            return true
        }
        loadHtml(code: NETWORK_ERROR.INVALID_URL)
        return false
    }
    
    private func validUrl(urlStr: String) -> Bool {
        return (urlStr != "http://") && (urlStr != "https://") &&
               ((urlStr.hasPrefix("http://") == true) || (urlStr.hasPrefix("https://") == true))
    }
    
    func loadHtml(code: NETWORK_ERROR) {
        let path: String = { _ in
            if code == NETWORK_ERROR.TIMEOUT { return Bundle.main.path(forResource: "timeout", ofType: "html")! }
            if code == NETWORK_ERROR.DNS_NOT_FOUND { return Bundle.main.path(forResource: "dns", ofType: "html")! }
            if code == NETWORK_ERROR.OFFLINE { return Bundle.main.path(forResource: "offline", ofType: "html")! }
            if code == NETWORK_ERROR.UNAUTHORIZED { return Bundle.main.path(forResource: "authorize", ofType: "html")! }
            return Bundle.main.path(forResource: "invalid", ofType: "html")!
        }()
            
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
    
    func isLocalRequest() -> Bool {
        return (self.url?.absoluteString.hasPrefix("file://"))!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
