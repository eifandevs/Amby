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
    
    static func realmConfiguration(realmEncryptionToken: String) -> Realm.Configuration {
        var config = Realm.Configuration()
        config.encryptionKey = realmEncryptionToken.data(using: String.Encoding.utf8, allowLossyConversion: false)
        config.fileURL = RealmHelper.realmFileURL()
        return config
    }
    
    static func realmFileURL() -> URL? {
        // Databaseディレクトリがなかったら生成する
        Util.createFolder(path: AppConst.realmPath)
        
        let realmPath = AppConst.realmPath + "/transaction.realm"
        
        return URL(fileURLWithPath: realmPath)
    }
}
