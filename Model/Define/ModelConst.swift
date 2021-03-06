//
//  ModelConst.swift
//  Model
//
//  Created by tenma on 2018/09/02.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

/// アプリ内定数構造体
struct ModelConst {

    // MARK: - 共通

    static let APP = ModelConst.APP_VALUE()
    struct APP_VALUE {
        let FONT = "Avenir"
        let DATE_FORMAT = "yyyyMMdd"
        let LOCALE = "ja_JP"
        let QUEUE = "com.eifandevs.amby.queue"
    }

    // MARK: - キー情報

    static let KEY = KEY_VALUE()
    struct KEY_VALUE {
        let REALM_TOKEN = ResourceUtil().get(key: "KEY_REALM_TOKEN")
        let ENCRYPT_SERVICE_TOKEN = ResourceUtil().get(key: "KEY_ENCRYPT_SERVICE_TOKEN")
        let ENCRYPT_IV_TOKEN = ResourceUtil().get(key: "KEY_ENCRYPT_IV_TOKEN")
        let GITHUB_ACCESS_TOKEN = ResourceUtil().get(key: "GITHUB_ACCESS_TOKEN")
        let OWNER = "eifandevs"
        let REPOSITORY = "IssueTest"
        let ROOT_PASSCODE = "rootPasscode"
        let LAST_REPORT_DATE = "lastReportDate"
        let AUTO_SCROLL_INTERVAL = "autoScrollInterval"
        let COMMON_HISTORY_SAVE_COUNT = "commonHistorySaveCount"
        let SEARCH_HISTORY_SAVE_COUNT = "searchHistorySaveCount"
        let TAB_SAVE_COUNT = "tabSaveCount"
        let NEW_WINDOW_CONFIRM = "newWindowConfirm"
        let MENU_ORDER = "menuOrder"
        let NOTIFICATION_SUBTITLE = "subtitle"
        let NOTIFICATION_MESSAGE = "message"
        let NOTIFICATION_OPERATION = "operation"
        let NOTIFICATION_OBJECT = "object"
        let NOTIFICATION_CONTEXT = "context"
        let NOTIFICATION_PAGE_EXIST = "pageExist"
        let NOTIFICATION_DELETE_INDEX = "deleteIndex"
        let NOTIFICATION_AT = "at"
    }

    // MARK: - UD初期値

    static let UD = UD_VALUE()
    struct UD_VALUE {
        let ROOT_PASSCODE = Data()
        let LAST_REPORT_DATE = Date.distantPast
        let AUTO_SCROLL_INTERVAL = 0.06
        let MENU_ORDER: [UserOperation] = [
            .menu,
            .close,
            .historyBack,
            .copy,
            .search,
            .add,
            .scrollUp,
            .autoScroll,
            .historyForward,
            .form,
            .closeAll,
            .grep
        ]
        let COMMON_HISTORY_SAVE_COUNT = 90
        let SEARCH_HISTORY_SAVE_COUNT = 90
        let TAB_SAVE_COUNT = 30
        let NEW_WINDOW_CONFIRM = false
    }

    // MARK: - DEVICE情報

    static let DEVICE = DEVICE_VALUE()
    struct DEVICE_VALUE {
        let STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.height
        let DISPLAY_SIZE = UIScreen.main.bounds.size
        let CACHES_PATH = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let ASPECT_RATE = UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
    }

    // MARK: - 認証情報
    static let CREDENTIAL = CREDENTIAL_VALUE()
    struct CREDENTIAL_VALUE {
        let APP_SERVER_ACCESS_ID = ResourceUtil().get(key: "APP_SERVER_ACCESS_ID")
        let APP_SERVER_ACCESS_PASSWORD = ResourceUtil().get(key: "APP_SERVER_ACCESS_PASSWORD")
    }

    // MARK: - URL情報

    static let URL = URL_VALUE()
    struct URL_VALUE {
        let SEARCH_PATH = "https://www.google.co.jp/search?q="

        // オートコンプリートAPI
        let SUGGEST_SERVER_DOMAIN = ResourceUtil().get(key: "SUGGEST_SERVER_DOMAIN")
        let SUGGEST_SERVER_PATH = ResourceUtil().get(key: "SUGGEST_SERVER_PATH")

        // アプリAPI
        let APP_SERVER_DOMAIN = ResourceUtil().get(key: "APP_SERVER_DOMAIN")

        // パス
        let ARTICLE_API_PATH = ResourceUtil().get(key: "ARTICLE_API_PATH")
        let FAVORITE_API_PATH = ResourceUtil().get(key: "FAVORITE_API_PATH")
        let ACCESSTOKEN_API_PATH = ResourceUtil().get(key: "ACCESSTOKEN_API_PATH")

        // トレンドホーム
        let TREND_HOME_URL = ResourceUtil().get(key: "TREND_HOME_URL")

        // ソース
        let SOURCE_URL = ResourceUtil().get(key: "SOURCE_URL")

        // issue
        let ISSUE_URL = ResourceUtil().get(key: "ISSUE_URL")
    }

    // MARK: - Appステータスコード

    static let APP_STATUS_CODE = APP_STATUS_CODE_VALUE()
    struct APP_STATUS_CODE_VALUE {
        let NORMAL = "0000"
        let PARSE_ERROR = "1000"
    }
}
