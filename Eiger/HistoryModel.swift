//
//  HistoryModel.swift
//  Eiger
//
//  Created by temma on 2017/02/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

import RealmSwift

class HistoryModel: ModelBase {
    
    func select() -> [History] {
        return realm.objects(History.self).map { $0 }
    }
    
    func delete() {
        try! realm.write {
            realm.delete(select())
        }
    }
}
