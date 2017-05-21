//
//  Favorite.swift
//  one-hand-browsing
//
//  Created by user1 on 2016/07/28.
//  Copyright © 2016年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

class Favorite: Object {
    dynamic var id: String = NSUUID().uuidString
    dynamic var title: String = ""
    dynamic var url: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
