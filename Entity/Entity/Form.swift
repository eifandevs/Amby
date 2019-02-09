//
//  Form.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

public class Form: Object {
    @objc public dynamic var id: String = NSUUID().uuidString
    @objc public dynamic var title: String = ""
    @objc public dynamic var host: String = ""
    @objc public dynamic var url: String = ""
    @objc public dynamic var date: Date = Date()
    public let inputs = List<Input>()

    public override static func primaryKey() -> String? {
        return "id"
    }
}
