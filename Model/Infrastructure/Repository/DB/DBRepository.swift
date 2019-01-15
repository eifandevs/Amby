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
            realm = try Realm(configuration: RealmHelper.realmConfiguration(realmEncryptionToken: AuthDataModel.s.realmEncryptionToken))
        } catch let error as NSError {
            log.error("Realm initialize error. description: \(error.description)")
            realm = nil
        }
    }

    func insert(data: [Object]) -> RepositoryResult<()> {
        do {
            try realm.write {
                realm.add(data, update: true)
            }
        } catch let error as NSError {
            log.error("realm write error. error: \(error.localizedDescription)")
            return .failure(error)
        }

        return .success(())
    }

    func update(action: (() -> Void)) -> RepositoryResult<()> {
        do {
            try realm.write {
                action()
            }
        } catch let error as NSError {
            log.error("realm update error. error: \(error.localizedDescription)")
            return .failure(error)
        }

        return .success(())
    }

    func delete(data: [Object]) -> RepositoryResult<()> {
        do {
            try realm.write {
                realm.delete(data)
            }
        } catch let error as NSError {
            log.error("realm write error. error: \(error.localizedDescription)")
            return .failure(error)
        }

        return .success(())
    }

    public func select<T>(_ type: T.Type) -> RepositoryResult<[T]> {
        let favorite = Array(realm.objects(type as! Object.Type))
        return .success(favorite as! [T])
    }
}
