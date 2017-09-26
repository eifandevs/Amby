//
//  RealmHelper.swift
//  Qas
//
//  Created by temma on 2017/07/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import RealmSwift
import Realm

final class RealmHelper {
    
    static func realmConfiguration() -> Realm.Configuration {
        var config = Realm.Configuration()
        config.encryptionKey = RealmHelper.realmEncryptionKey()
        config.fileURL = RealmHelper.realmFileURL()
        return config
    }
    
    static func realmEncryptionKey() -> Data? {
        // 暗号化キー文字列は、定数クラスから呼び出す
        return AppConst.realmkey.data(using: String.Encoding.utf8, allowLossyConversion: false)
    }
    
    static func realmFileURL() -> URL? {
        // Databaseディレクトリがなかったら生成する
        Util.createFolder(path: AppConst.realmPath)
        
        let realmPath = AppConst.realmPath + "/transaction.realm"
        
        return URL(fileURLWithPath: realmPath)
    }
}
