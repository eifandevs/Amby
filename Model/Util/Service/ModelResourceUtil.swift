//
//  AppResourceUtil.swift
//  Model
//
//  Created by tenma on 2018/09/02.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class ModelResourceUtil {
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
}
