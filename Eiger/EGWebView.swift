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
    var context = NSUUID().uuidString // 監視ID
    var previousUrl: String = "" // リロードしたページを履歴に登録しないために、前回URLを保持しておく
    var hasSavableUrl: Bool {
        get {
            return  previousUrl != requestUrl &&
                    requestUrl.hasValidUrl
        }
    }
    
    var hasValidUrl: Bool {
        get {
            if let url = url {
                return url.absoluteString.hasValidUrl
            }
            return false
        }
    }
    
    var hasLocalUrl: Bool {
        get {
            if let url = url {
                return url.absoluteString.hasLocalUrl
            }
            return false
        }
    }
    
    init(id: String?, pool: WKProcessPool) {
        if let id = id, !id.isEmpty {
            // コンテキストを復元
            context = id
        }
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
        if  urlStr.hasValidUrl {
            guard let url = URL(string: urlStr) else {
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
    
    func takeThumbnail() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: bounds.size.width, height: bounds.size.width * DeviceDataManager.shared.aspectRate), true, 0);
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false);
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshotImage?.crop(w: Int(AppDataManager.shared.thumbnailSize.width * 2), h: Int((AppDataManager.shared.thumbnailSize.width * 2) * DeviceDataManager.shared.aspectRate));
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
