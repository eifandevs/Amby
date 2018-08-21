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
        do {
            try realm.write {
                realm.add(data, update: true)
            }
        } catch let error as NSError {
            log.error("realm write error. error: \(error.localizedDescription)")
        }
    }

    func delete(data: [Object]) {
        do {
            try realm.write {
                realm.delete(data)
            }
        } catch let error as NSError {
            log.error("realm write error. error: \(error.localizedDescription)")
        }
    }

    func select(type: Object.Type) -> [Object] {
        return realm.objects(type).map { $0 }
    }
}
