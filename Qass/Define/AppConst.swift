//
//  AppDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

/// アプリ内定数構造体
struct AppConst {

    // MARK: - 共通

    static let APP = AppConst.APP_VALUE()
    struct APP_VALUE {
        let FONT = "Avenir"
        let DATE_FORMAT = "yyyyMMdd"
        let LOCALE = "ja_JP"
    }

    // MARK: - フロントレイヤーの定数

    static let FRONT_LAYER = AppConst.FRONT_LAYER_VALUE()
    struct FRONT_LAYER_VALUE {
        let TABLE_VIEW_CELL_HEIGHT = 50.f
        let TABLE_VIEW_LICENSE_CELL_HEIGHT = 44.f
        let TABLE_VIEW_NEWS_CELL_HEIGHT = 85.f
        let TABLE_VIEW_SECTION_HEIGHT = 19.f
        let SEARCH_TABLE_VIEW_ROW_NUM = 2
        let EDGE_SWIPE_EREA = 15.f
        let OVER_VIEW_MARGIN = CGPoint(x: 30.f, y: 18.f)
        let OPTION_MENU_SIZE = CGSize(width: 250, height: 450)
        let OPTION_MENU_MARGIN = CGSize(width: 38, height: 20)
    }

    // MARK: - ベースレイヤーの定数

    static var BASE_LAYER = AppConst.BASE_LAYER_VALUE()
    struct BASE_LAYER_VALUE {
        var HEADER_HEIGHT = ((UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height) * 1.3 // サムネイルの高さ * 1.3
        var HEADER_FIELD_HEIGHT = (((UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height) * 1.3) / 2 // ヘッダーの高さ / 2
        let HEADER_PROGRESS_BAR_HEIGHT = 2.1.f
        var HEADER_PROGRESS_MARGIN = 2.1.f // プログレスバーの高さをマージンにする
        var FOOTER_HEIGHT = ((UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height) // サムネイルの高さ
        let BASE_HEIGHT = AppConst.DEVICE.DISPLAY_SIZE.height - (((UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)) - AppConst.DEVICE.STATUS_BAR_HEIGHT // デバイスの高さ - フッターの高さ - ステータスバーの高さ
        let HEADER_FIELD_WIDTH = AppConst.DEVICE.DISPLAY_SIZE.width / 1.8
        var THUMBNAIL_SIZE = CGSize(width: UIScreen.main.bounds.size.width / 4.3, height: (UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)
    }

    // MARK: - キー情報

    static let KEY = KEY_VALUE()
    struct KEY_VALUE {
        let REALM_TOKEN = ResourceUtil().get(key: "KEY_REALM_TOKEN")
        let ENCRYPT_SERVICE_TOKEN = ResourceUtil().get(key: "KEY_ENCRYPT_SERVICE_TOKEN")
        let ENCRYPT_IV_TOKEN = ResourceUtil().get(key: "KEY_ENCRYPT_IV_TOKEN")
        let NOTIFICATION_SUBTITLE = "subtitle"
        let NOTIFICATION_MESSAGE = "message"
        let NOTIFICATION_OPERATION = "operation"
        let NOTIFICATION_OBJECT = "object"
        let NOTIFICATION_CONTEXT = "context"
        let NOTIFICATION_PAGE_EXIST = "pageExist"
        let NOTIFICATION_DELETE_INDEX = "deleteIndex"
        let NOTIFICATION_AT = "at"
    }

    // MARK: - メニュー画面

    static let OPTION_MENU = OPTION_MENU_VALUE()
    struct OPTION_MENU_VALUE {
        let TREND = "トレンド"
        let HISTORY = "閲覧履歴"
        let MENU = "メニュー並び替え"
        let FORM = "フォーム"
        let BOOKMARK = "ブックマーク"
        let SETTING = "設定"
        let HELP = "ヘルプ"
        let APP_INFORMATION = "Qass"
    }

    // MARK: - アプリ情報

    static let APP_INFORMATION = APP_INFORMATION_VALUE()
    struct APP_INFORMATION_VALUE {
        let OPENSOURCE = "オープンソースライセンス"
        let POLICY = "プライバシーポリシー"
        let SOURCE = "ソースコード"
        let CONTACT = "お問い合わせ"
        let REPORT = "問題の報告/ご意見"
    }

    // MARK: - 設定画面

    static let SETTING = SETTING_VALUE()
    struct SETTING_VALUE {
        let SECTION_AUTO_SCROLL = "自動スクロール設定"
        let SECTION_MENU = "メニュー設定"
        let SECTION_HISTORY = "履歴保存件数（何日分）"
        let SECTION_DELETE = "データ削除"
        let TITLE_COMMON_HISTORY = "閲覧履歴"
        let TITLE_SEARCH_HISTORY = "検索履歴"
        let TITLE_BOOK_MARK = "ブックマーク"
        let TITLE_FORM_DATA = "フォームデータ"
        let TITLE_COOKIES = "Cookie"
        let TITLE_SITE_DATA = "サイトデータ"
        let TITLE_ALL = "全てのデータ"
    }

    // MARK: - UD初期値

    static let UD = UD_VALUE()
    struct UD_VALUE {
        let CURRENT_CONTEXT = ""
        let AUTO_SCROLL = 0.06
        let COMMON_HISTORY_SAVE_COUNT = 90
        let SEARCH_HISTORY_SAVE_COUNT = 90
        let PAGE_HISTORY_SAVE_COUNT = 30
    }

    // MARK: - URL情報

    static let URL = URL_VALUE()
    struct URL_VALUE {
        let BLANK = "about:blank"
        let ITUNES_STORE = "//itunes.apple.com/"
        let DB_PATH = AppConst.DEVICE.CACHES_PATH + "/database"
        let SEARCH_PATH = "https://www.google.co.jp/search?q="

        // トレンドホーム
        let TREND_HOME_URL = ResourceUtil().get(key: "TREND_HOME_URL")

        // ソース
        let SOURCE_URL = ResourceUtil().get(key: "SOURCE_URL")
    }

    // MARK: - Appステータスコード

    static let APP_STATUS_CODE = APP_STATUS_CODE_VALUE()
    struct APP_STATUS_CODE_VALUE {
        let NORMAL = "0000"
        let PARSE_ERROR = "1000"
    }

    // MARK: - DEVICE情報

    static let DEVICE = DEVICE_VALUE()
    struct DEVICE_VALUE {
        let STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.height
        let DISPLAY_SIZE = UIScreen.main.bounds.size
        let CACHES_PATH = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let DOCUMENT_PATH = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let APPLICATION_PATH = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first!
        let RESOURCE_PATH = Bundle.main.resourcePath!
        let BUNDLE_PATH = Bundle.main.bundlePath
        let ASPECT_RATE = UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
    }
}
