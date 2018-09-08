//
//  Favorite.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

public class Favorite: Object {
    @objc public dynamic var id: String = NSUUID().uuidString
    @objc public dynamic var title: String = ""
    @objc public dynamic var url: String = ""

    public override static func primaryKey() -> String? {
        return "id"
    }
}
