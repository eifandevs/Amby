//
//  ResourceUtil.swift
//  Qass
//
//  Created by tenma on 2018/08/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class ResourceUtil {
    /// 環境データ取得
    func get(key: String) -> String {
        return envList[key] as? String ?? ""
    }

    /// 環境設定
    private var envList: NSDictionary = {
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

    /// ライセンリスト
    var licenseList: Foundation.URL = R.file.comMono0926LicensePlistPlist()!

    /// タイムアウトページ
    var timeoutHtml: Foundation.URL = R.file.timeoutHtml()!

    /// DNSエラーページ
    var dnsHtml: Foundation.URL = R.file.dnsHtml()!

    /// オフラインエラーページ
    var offlineHtml: Foundation.URL = R.file.offlineHtml()!

    /// 認証エラーページ
    var authorizeHtml: Foundation.URL = R.file.authorizeHtml()!

    /// 汎用エラーページ
    var invalidHtml: Foundation.URL = R.file.invalidHtml()!

    /// ハイライトスクリプト
    var highlightScript: Foundation.URL = R.file.highlightJs()!
}
