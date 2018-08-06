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
    static let SUGGEST_SERVER_DOMAIN = EnvDataModel.s.get(key: "SUGGEST_SERVER_DOMAIN")
    static let SUGGEST_SERVER_PATH = EnvDataModel.s.get(key: "SUGGEST_SERVER_PATH")

    // アプリAPI
    static let APP_SERVER_DOMAIN = EnvDataModel.s.get(key: "APP_SERVER_DOMAIN")
    static let APP_SERVER_PATH = EnvDataModel.s.get(key: "APP_SERVER_PATH")

    // トレンドホーム
    static let TREND_HOME_URL = EnvDataModel.s.get(key: "TREND_HOME_URL")

    static let PATH_SEARCH = "https://www.google.co.jp/search?q="

    // Appステータスコード
    enum APP_STATUS_CODE: String {
        case NORMAL = "0000"
        case PARSE_ERROR = "1000"
    }
}
