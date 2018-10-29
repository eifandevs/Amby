//
//  Memo.swift
//  Model
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RealmSwift

public class Memo: Object {
    @objc public dynamic var id: String = NSUUID().uuidString
    @objc public dynamic var text: String = ""

    public override static func primaryKey() -> String? {
        return "id"
    }
}
