//
//  HttpConst.swift
//  Qas
//
//  Created by temma on 2017/08/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

final class HttpConst {
    // オートコンプリートAPI
    static let SUGGEST_SERVER_DOMAIN = EnvDataModel.s.getEnv(key: "SUGGEST_SERVER_DOMAIN")
    static let SUGGEST_SERVER_PATH = EnvDataModel.s.getEnv(key: "SUGGEST_SERVER_PATH")

    // アプリAPI
    static let APP_SERVER_DOMAIN = EnvDataModel.s.getEnv(key: "APP_SERVER_DOMAIN")
    static let APP_SERVER_PATH = EnvDataModel.s.getEnv(key: "APP_SERVER_PATH")

    // ニュースホーム
    static let HOME_URL = EnvDataModel.s.getEnv(key: "HOME_URL") ?? "https://"

    // Appステータスコード
    enum APP_STATUS_CODE: String {
        case NORMAL = "0000"
        case PARSE_ERROR = "1000"
    }
}
