//
//  HttpConst.swift
//  Qas
//
//  Created by temma on 2017/08/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

struct HttpConst {
    static let URL = URL_VALUE()
    struct URL_VALUE {
        // オートコンプリートAPI
        let SUGGEST_SERVER_DOMAIN = ResourceUtil().get(key: "SUGGEST_SERVER_DOMAIN")
        let SUGGEST_SERVER_PATH = ResourceUtil().get(key: "SUGGEST_SERVER_PATH")

        // アプリAPI
        let APP_SERVER_DOMAIN = ResourceUtil().get(key: "APP_SERVER_DOMAIN")
        let APP_SERVER_PATH = ResourceUtil().get(key: "APP_SERVER_PATH")

        // トレンドホーム
        let TREND_HOME_URL = ResourceUtil().get(key: "TREND_HOME_URL")

        // ソース
        let SOURCE_URL = ResourceUtil().get(key: "SOURCE_URL")

        let SEARCH_PATH = "https://www.google.co.jp/search?q="
    }

    // Appステータスコード
    static let APP_STATUS_CODE = APP_STATUS_CODE_VALUE()
    struct APP_STATUS_CODE_VALUE {
        let NORMAL = "0000"
        let PARSE_ERROR = "1000"
    }
}
