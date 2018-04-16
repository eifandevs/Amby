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
    static var SUGGEST_SERVER_DOMAIN = "https://"
    static var SUGGEST_SERVER_PATH = ""

    // アプリAPI
    static var APP_SERVER_DOMAIN = "https://"
    static var APP_SERVER_PATH = ""

    // ニュースホーム
    static var HOME_URL = "https://google.com"

    // Appステータスコード
    enum APP_STATUS_CODE: String {
        case NORMAL = "0000"
        case PARSE_ERROR = "1000"
    }
}
