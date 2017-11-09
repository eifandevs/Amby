//
//  FavoriteDataModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteDataModel {
    static func insert(favorites: [Favorite]) {
        CommonDao.s.insert(data: favorites)
    }
    
    static func select(id: String? = nil, url: String? = nil) -> [Favorite] {
        let favorites = CommonDao.s.select(type: Favorite.self) as! [Favorite]
        if let id = id {
            return favorites.filter({ $0.id == id })
        } else if let url = url {
            return favorites.filter({ $0.url == url })
        }
        return favorites
    }
    
    static func delete(favorites: [Favorite]? = nil) {
        if let favorites = favorites {
            CommonDao.s.delete(data: favorites)
        } else {
            // 削除対象が指定されていない場合は、すべて削除する
            CommonDao.s.delete(data: select())
        }
    }
}

class Favorite: Object {
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var url: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
