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

    struct APP {
        static let FONT = "Avenir"
        static let DATE_FORMAT = "yyyyMMdd"
        static let LOCALE = "ja_JP"
    }

    // MARK: - フロントレイヤーの定数

    struct FRONT_LAYER {
        static let TABLE_VIEW_CELL_HEIGHT = 50.f
        static let TABLE_VIEW_LICENSE_CELL_HEIGHT = 44.f
        static let TABLE_VIEW_FORM_CELL_HEIGHT = 44.f
        static let TABLE_VIEW_MENU_ORDER_CELL_HEIGHT = 47.f
        static let TABLE_VIEW_MEMO_CELL_HEIGHT = 47.f
        static let TABLE_VIEW_NEWS_CELL_HEIGHT = 85.f
        static let TABLE_VIEW_SECTION_HEIGHT = 19.f
        static let SEARCH_TABLE_VIEW_ROW_NUM = 2
        static let EDGE_SWIPE_EREA = 15.f
        static let OVER_VIEW_MARGIN = CGPoint(x: 30.f, y: 18.f)
        static let OPTION_MENU_SIZE = CGSize(width: 250, height: 450)
        static let OPTION_MENU_MARGIN = CGSize(width: 38, height: 20)
        static let CIRCLEMENU_ROW_NUM = 6
        static let CIRCLEMENU_SECTION_NUM = 2
    }

    // MARK: - ベースレイヤーの定数

    struct BASE_LAYER {
        static var HEADER_HEIGHT = ((UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height) * 1.3 // サムネイルの高さ * 1.3
        static var HEADER_FIELD_HEIGHT = (((UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height) * 1.3) / 2 // ヘッダーの高さ / 2
        static let HEADER_PROGRESS_BAR_HEIGHT = 2.1.f
        static var HEADER_PROGRESS_MARGIN = 2.1.f // プログレスバーの高さをマージンにする
        static var FOOTER_HEIGHT = ((UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height) // サムネイルの高さ
        static let BASE_HEIGHT = AppConst.DEVICE.DISPLAY_SIZE.height - (((UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)) - AppConst.DEVICE.STATUS_BAR_HEIGHT // デバイスの高さ - フッターの高さ - ステータスバーの高さ
        static let HEADER_FIELD_WIDTH = AppConst.DEVICE.DISPLAY_SIZE.width / 1.8
        static var THUMBNAIL_SIZE = CGSize(width: UIScreen.main.bounds.size.width / 4.3, height: (UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)
    }

    // MARK: - キー情報

    struct KEY {
        static let REALM_TOKEN = ResourceUtil().get(key: "KEY_REALM_TOKEN")
        static let ENCRYPT_SERVICE_TOKEN = ResourceUtil().get(key: "KEY_ENCRYPT_SERVICE_TOKEN")
        static let ENCRYPT_IV_TOKEN = ResourceUtil().get(key: "KEY_ENCRYPT_IV_TOKEN")
        static let NOTIFICATION_SUBTITLE = "subtitle"
        static let NOTIFICATION_MESSAGE = "message"
        static let NOTIFICATION_OPERATION = "operation"
        static let NOTIFICATION_OBJECT = "object"
        static let NOTIFICATION_CONTEXT = "context"
        static let NOTIFICATION_PAGE_EXIST = "pageExist"
        static let NOTIFICATION_DELETE_INDEX = "deleteIndex"
        static let NOTIFICATION_AT = "at"
    }

    // MARK: - メニュー画面

    struct OPTION_MENU {
        static let TAB_GROUP = "タブグループ"
        static let TREND = "トレンド"
        static let HISTORY = "閲覧履歴"
        static let MENU = "メニュー並び替え"
        static let PASSCODE = "ルートパスワード設定"
        static let FORM = "フォーム"
        static let BOOKMARK = "ブックマーク"
        static let MEMO = "メモ"
        static let SETTING = "設定"
        static let HELP = "ヘルプ"
        static let COORERATION = "協力"
        static let DONATION = "寄付"
        static let DEVELOPMENT = "開発"
        static let APP_INFORMATION = "Amby"
        static let UNLOCK = "開錠"
        static let LOCK = "施錠"
        static let DELETE = "削除"
    }

    // MARK: - アプリ情報

    struct APP_INFORMATION {
        static let OPENSOURCE = "オープンソースライセンス"
        static let POLICY = "プライバシーポリシー"
        static let SOURCE = "ソースコード"
        static let CONTACT = "お問い合わせ"
        static let REPORT = "問題の報告/ご意見"
    }

    // MARK: - 設定画面

    struct SETTING {
        static let SECTION_AUTO_SCROLL = "自動スクロール設定"
        static let SECTION_SETTING = "初期設定"
        static let SECTION_HISTORY = "履歴保存件数（何日分）"
        static let SECTION_DELETE = "データ削除"
        static let TITLE_COMMON_HISTORY = "閲覧履歴"
        static let TITLE_SEARCH_HISTORY = "検索履歴"
        static let TITLE_BOOK_MARK = "ブックマーク"
        static let TITLE_FORM_DATA = "フォームデータ"
        static let TITLE_COOKIES = "Cookie"
        static let TITLE_SITE_DATA = "サイトデータ"
        static let TITLE_ALL = "全てのデータ"
    }

    // MARK: - UD初期値

    struct UD {
        static let CURRENT_CONTEXT = ""
        static let AUTO_SCROLL = 0.06
        static let COMMON_HISTORY_SAVE_COUNT = 90
        static let SEARCH_HISTORY_SAVE_COUNT = 90
        static let PAGE_HISTORY_SAVE_COUNT = 30
    }

    // MARK: - URL情報

    struct URL {
        static let BLANK = "about:blank"
        static let ITUNES_STORE = "//itunes.apple.com/"
        static let DB_PATH = AppConst.DEVICE.CACHES_PATH + "/database"
        static let SEARCH_PATH = "https://www.google.co.jp/search?q="

        // トレンドホーム
        static let TREND_HOME_URL = ResourceUtil().get(key: "TREND_HOME_URL")

        // ソース
        static let SOURCE_URL = ResourceUtil().get(key: "SOURCE_URL")
    }

    // MARK: - Appステータスコード

    struct APP_STATUS_CODE {
        static let NORMAL = "0000"
        static let PARSE_ERROR = "1000"
    }

    // MARK: - DEVICE情報

    struct DEVICE {
        static let STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.height
        static let DISPLAY_SIZE = UIScreen.main.bounds.size
        static let CACHES_PATH = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        static let DOCUMENT_PATH = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        static let APPLICATION_PATH = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first!
        static let RESOURCE_PATH = Bundle.main.resourcePath!
        static let BUNDLE_PATH = Bundle.main.bundlePath
        static let ASPECT_RATE = UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
    }
}
