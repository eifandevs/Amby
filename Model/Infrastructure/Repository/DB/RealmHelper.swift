//
//  RealmHelper.swift
//  Amby
//
//  Created by temma on 2017/07/04.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Realm
import RealmSwift

final class RealmHelper {
    static func realmConfiguration(realmEncryptionToken: String) -> Realm.Configuration {
        var config = Realm.Configuration()
        config.encryptionKey = realmEncryptionToken.data(using: String.Encoding.utf8, allowLossyConversion: false)
        config.fileURL = Cache.database(resource: "transaction.realm").url
        return config
    }
}
