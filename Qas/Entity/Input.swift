//
//  Input.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

class Input: Object {
    @objc dynamic var formIndex: Int = 0
    @objc dynamic var formInputIndex: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var value: Data = Data()
}
