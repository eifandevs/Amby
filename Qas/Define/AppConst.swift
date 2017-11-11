//
//  AppDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

/// アプリ内定数クラス
final class AppConst {
    // MARK: - 共通
    static let APP_FONT = "Avenir"
    static let DATE_FORMAT = "yyyyMMdd"
    
    // MARK: - フロントレイヤーの定数
    static let FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT = 50.f
    static let FRONT_LAYER_TABLE_VIEW_SECTION_HEIGHT = 17.f
    static let FRONT_LAYER_EDGE_SWIPE_EREA = 15.f
    static let FRONT_LAYER_OPTION_MENU_SIZE = CGSize(width: 250, height: 450)
    
    // MARK: - ベースレイヤーの定数
    static let BASE_LAYER_HEADER_HEIGHT = AppConst.BASE_LAYER_THUMBNAIL_SIZE.height * 1.3
    static let BASE_LAYER_HEADER_FIELD_WIDTH = DeviceConst.DISPLAY_SIZE.width / 1.8
    static let BASE_LAYER_THUMBNAIL_SIZE = CGSize(width: UIScreen.main.bounds.size.width / 4.3, height: (UIScreen.main.bounds.size.width / 4.3) * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)

    // MARK: - キー情報
    static let KEY_REALM_TOKEN = "com.eifaniori.qas-realm-token"
    static let KEY_ENCRYPT_SERVICE_TOKEN = "com.eifaniori.qas-encrypt-service-token"
    static let KEY_ENCRYPT_IV_TOKEN = "com.eifaniori.qas-encrypt-Iv-token"
    static let KEY_LOCATION_INDEX = "locationIndex"
    static let KEY_AUTO_SCROLL_INTERVAL = "autoScrollInterval"
    static let KEY_HISTORY_SAVE_TERM = "historySaveTerm"
    static let KEY_SEARCH_HISTORY_SAVE_TERM = "searchHistorySaveTerm"
    
    // MARK: - パス情報
    static let PATH_SEARCH = "https://www.google.co.jp/search?q="
    static let PATH_PAGE_HISTORY = DeviceConst.CACHES_PATH + "/each_history.dat"
    static let PATH_COMMON_HISTORY = DeviceConst.CACHES_PATH + "/common_history"
    static let PATH_SEARCH_HISTORY = DeviceConst.CACHES_PATH + "/search_history"
    static let PATH_THUMBNAIL = DeviceConst.CACHES_PATH + "/thumbnails"
    static let PATH_DB = DeviceConst.CACHES_PATH + "/database"
    static let PATH_URL_PAGE_HISTORY = URL(fileURLWithPath: AppConst.PATH_PAGE_HISTORY)
    
    // MARK: - 設定画面
    static let SETTING_SECTION_AUTO_SCROLL = "自動スクロール設定"
    static let SETTING_SECTION_HISTORY = "履歴保存件数（何日分）"
    static let SETTING_SECTION_DELETE = "データ削除"
    static let SETTING_TITLE_COMMON_HISTORY = "閲覧履歴"
    static let SETTING_TITLE_SEARCH_HISTORY = "検索履歴"
    static let SETTING_TITLE_BOOK_MARK = "ブックマーク"
    static let SETTING_TITLE_FORM_DATA = "フォームデータ"
    static let SETTING_TITLE_COOKIES = "Cookie"
    static let SETTING_TITLE_SITE_DATA = "サイトデータ"
    static let SETTING_TITLE_ALL = "全てのデータ"

}
