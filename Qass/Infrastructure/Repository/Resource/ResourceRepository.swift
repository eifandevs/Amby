//
//  ResourceRepository.swift
//  Qass
//
//  Created by tenma on 2018/06/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class ResourceRepository {
    /// 環境設定
    var envList: NSDictionary = {
        let domainPath = Bundle.main.path(forResource: "env", ofType: "plist")
        if let plist = NSDictionary(contentsOfFile: domainPath!) {
            log.debug("use existed env.")
            return plist
        } else {
            log.debug("use dummy env.")
            let domainPath = Bundle.main.path(forResource: "env-dummy", ofType: "plist")
            let plist = NSDictionary(contentsOfFile: domainPath!)!
            return plist
        }
    }()

    /// タイムアウトページ
    var timeoutHtml: Foundation.URL = {
        let fileResource = R.file.timeoutHtml
        return fileResource.bundle.url(forResource: fileResource)!
    }()

    /// DNSエラーページ
    var dnsHtml: Foundation.URL = {
        let fileResource = R.file.dnsHtml
        return fileResource.bundle.url(forResource: fileResource)!
    }()

    /// オフラインエラーページ
    var offlineHtml: Foundation.URL = {
        let fileResource = R.file.offlineHtml
        return fileResource.bundle.url(forResource: fileResource)!
    }()

    /// 認証エラーページ
    var authorizeHtml: Foundation.URL = {
        let fileResource = R.file.authorizeHtml
        return fileResource.bundle.url(forResource: fileResource)!
    }()

    /// 汎用エラーページ
    var invalidHtml: Foundation.URL = {
        let fileResource = R.file.invalidHtml
        return fileResource.bundle.url(forResource: fileResource)!
    }()

    /// ハイライトスクリプト
    var highlightScript: Foundation.URL = {
        let fileResource = R.file.highlightJs
        return fileResource.bundle.url(forResource: fileResource)!
    }()
}
