//
//  ModelBase.swift
//  Eiger
//
//  Created by temma on 2017/02/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

import RealmSwift

class ModelBase {
    let realm: Realm
    
    init() {
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
}
