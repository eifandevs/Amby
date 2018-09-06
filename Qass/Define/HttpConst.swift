//
//  HttpConst.swift
//  Qass
//
//  Created by tenma on 2018/09/06.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

struct AppHttpConst {
    static let URL = URL_VALUE()
    struct URL_VALUE {
        let SEARCH_PATH = "https://www.google.co.jp/search?q="

        // トレンドホーム
        let TREND_HOME_URL = AppResourceUtil().get(key: "TREND_HOME_URL")

        // ソース
        let SOURCE_URL = AppResourceUtil().get(key: "SOURCE_URL")
    }

    // Appステータスコード
    static let APP_STATUS_CODE = APP_STATUS_CODE_VALUE()
    struct APP_STATUS_CODE_VALUE {
        let NORMAL = "0000"
        let PARSE_ERROR = "1000"
    }
}
