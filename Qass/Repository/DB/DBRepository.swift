//
//  DBRepositorywift
//  one-hand-browsing
//
//  Created by user1 on 2016/07/19.
//  Copyright © 2016年 eifaniori. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import UIKit

final class DBRepository {
    private let realm: Realm!

    init() {
        do {
            realm = try Realm(configuration: RealmHelper.realmConfiguration(realmEncryptionToken: AuthTokenDataModel.s.realmEncryptionToken))
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
}
