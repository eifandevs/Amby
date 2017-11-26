//
//  CommonDao.swift
//  one-hand-browsing
//
//  Created by user1 on 2016/07/19.
//  Copyright © 2016年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Realm

final class CommonDao {
    static let s = CommonDao()
    private let realm: Realm!
    let realmEncryptionToken: String!
    let keychainServiceToken: String!
    let keychainIvToken: String!
    
    private init() {
        // キーチェーンからトークン取得
        realmEncryptionToken = KeyChainHelper.getToken(key: AppConst.KEY_REALM_TOKEN)
        keychainServiceToken = KeyChainHelper.getToken(key: AppConst.KEY_ENCRYPT_SERVICE_TOKEN)
        keychainIvToken = KeyChainHelper.getToken(key: AppConst.KEY_ENCRYPT_IV_TOKEN)

        do {
            realm = try Realm(configuration: RealmHelper.realmConfiguration(realmEncryptionToken: realmEncryptionToken))
        } catch let error as NSError {
            log.error("Realm initialize error. description: \(error.description)")
            realm = nil
        }
    }

    func insert(data: [Object]) {
        try! realm.write {
            realm.add(data, update: true)
        }
    }
    
    func delete(data: [Object]) {
        try! realm.write {
            realm.delete(data)
        }
    }
    
    func select(type: Object.Type) -> [Object] {
        return realm.objects(type).map { $0 }
    }

    /// UDデフォルト値登録
    func registerDefaultData() {
        UserDefaults.standard.register(defaults: [AppConst.KEY_LOCATION_INDEX: AppConst.UD_LOCATION_INDEX,
                                                  AppConst.KEY_CURRENT_CONTEXT: AppConst.UD_CURRENT_CONTEXT,
                                                  AppConst.KEY_AUTO_SCROLL_INTERVAL: AppConst.UD_AUTO_SCROLL,
                                                  AppConst.KEY_HISTORY_SAVE_TERM: AppConst.UD_COMMON_HISTORY_SAVE_TERM,
                                                  AppConst.KEY_SEARCH_HISTORY_SAVE_TERM: AppConst.UD_SEARCH_HISTORY_SAVE_TERM])
    }
}
