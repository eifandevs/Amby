//
//  ResourceUtil.swift
//  Amby
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
    var licenseList = { () -> [(libraryName: String, description: String)] in
        do {
            let path = Bundle.main.bundlePath + "/com.mono0926.LicensePlist"
            let libraryNameList = try FileManager.default.contentsOfDirectory(atPath: path)

            let libraryList = libraryNameList.map { (fileName: String) -> (libraryName: String, description: String) in
                let libraryName = fileName.components(separatedBy: ".plist").first!
                let libraryPath = path + "/" + fileName
                let plist = NSDictionary(contentsOfFile: libraryPath)!

                let description = ((plist["PreferenceSpecifiers"] as? NSArray ?? []).firstObject as? NSDictionary ?? [:])["FooterText"] as? String ?? ""
                return (libraryName, description)
            }

            return libraryList
        } catch let error as NSError {
            log.error("get license list error. error: \(error.localizedDescription)")
            return [("", "")]
        }
    }()

    /// タイムアウトページ
    var timeoutHtml = R.file.timeoutHtml()!.path

    /// DNSエラーページ
    var dnsHtml = R.file.dnsHtml()!.path

    /// オフラインエラーページ
    var offlineHtml = R.file.offlineHtml()!.path

    /// 認証エラーページ
    var authorizeHtml = R.file.authorizeHtml()!.path

    /// 汎用エラーページ
    var invalidHtml = R.file.invalidHtml()!.path

    /// ハイライトスクリプト
    var highlightScript = R.file.highlightJs()!
}
