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
    var context = "" // 監視ID
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}
