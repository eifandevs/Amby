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

// MARK: サムネイル取得
    func getThumbnailImage(context: String) -> UIImage? {
        let image = UIImage(contentsOfFile: Util.thumbnailUrl(folder: context).path)
        return image?.crop(w: Int(AppConst.BASE_LAYER_THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER_THUMBNAIL_SIZE.width * 2) * DeviceConst.ASPECT_RATE))
    }
    
    func getCaptureImage(context: String) -> UIImage? {
        return UIImage(contentsOfFile: Util.thumbnailUrl(folder: context).path)
    }

    /// サムネイルデータの削除
    func deleteAllThumbnail() {
        Util.deleteFolder(path: AppConst.PATH_THUMBNAIL)
        Util.createFolder(path: AppConst.PATH_THUMBNAIL)
    }

    /// UDデフォルト値登録
    func registerDefaultData() {
        UserDefaults.standard.register(defaults: [AppConst.KEY_LOCATION_INDEX: 0,
                                                  AppConst.KEY_AUTO_SCROLL_INTERVAL: 0.06,
                                                  AppConst.KEY_HISTORY_SAVE_TERM: 90,
                                                  AppConst.KEY_SEARCH_HISTORY_SAVE_TERM: 90])
    }
}
