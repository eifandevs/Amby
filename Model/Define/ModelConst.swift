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

    // MARK: - キー情報

    static let KEY = KEY_VALUE()
    struct KEY_VALUE {
        let REALM_TOKEN = ModelResourceUtil().get(key: "KEY_REALM_TOKEN")
        let ENCRYPT_SERVICE_TOKEN = ModelResourceUtil().get(key: "KEY_ENCRYPT_SERVICE_TOKEN")
        let ENCRYPT_IV_TOKEN = ModelResourceUtil().get(key: "KEY_ENCRYPT_IV_TOKEN")
        let CURRENT_CONTEXT = "currentContext"
        let AUTO_SCROLL_INTERVAL = "autoScrollInterval"
        let COMMON_HISTORY_SAVE_COUNT = "historySaveCount"
        let SEARCH_HISTORY_SAVE_COUNT = "searchHistorySaveCount"
        let PAGE_HISTORY_SAVE_COUNT = "pageHistorySaveCount"
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
        let CURRENT_CONTEXT = ""
        let AUTO_SCROLL = 0.06
        let COMMON_HISTORY_SAVE_COUNT = 90
        let SEARCH_HISTORY_SAVE_COUNT = 90
        let PAGE_HISTORY_SAVE_COUNT = 30
    }
}
