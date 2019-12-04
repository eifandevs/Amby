//
//  Input.swift
//  Amby
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import RealmSwift

public class Input: Object, Codable {
    @objc public dynamic var formIndex: Int = 0
    @objc public dynamic var formInputIndex: Int = 0
    @objc public dynamic var type: String = ""
    @objc public dynamic var value: Data = Data()
}
