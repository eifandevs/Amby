//
//  StoreManager.swift
//  one-hand-browsing
//
//  Created by user1 on 2016/07/19.
//  Copyright © 2016年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

final class StoreManager {
    static let shared = StoreManager()
    private let realm: Realm
    
    private init() {
        realm = try! Realm()
    }

    func insertWithRLMObjects(data: [Object]) {
        try! realm.write {
            realm.add(data)
        }
    }
    
    func deleteWithRLMObjects(data: [Object]) {
        try! realm.write {
            realm.delete(data)
        }
    }
    
    // Favorite
    func selectAllFavoriteInfo() -> [Favorite] {
        return realm.objects(Favorite.self).map { $0 }
    }
}
