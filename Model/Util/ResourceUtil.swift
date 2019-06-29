//
//  AppResourceUtil.swift
//  Model
//
//  Created by tenma on 2018/09/02.
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
        let path = Bundle.main.privateFrameworksPath! + "/Model.framework/env.plist"

        if let plist = NSDictionary(contentsOfFile: path) {
            log.debug("use existed env.")
            return plist
        } else {
            log.debug("use dummy env.")
            let path = Bundle.main.privateFrameworksPath! + "/Model.framework/env-dummy.plist"
            let plist = NSDictionary(contentsOfFile: path)!
            return plist
        }
    }()

    /// Firebase path
    var firebaseConfigPath = Bundle.main.privateFrameworksPath! + "/Model.framework/GoogleService-Info.plist"
}
