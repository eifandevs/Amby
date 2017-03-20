//
//  AppDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class AppDataManager {
    static let shared: AppDataManager = AppDataManager()
    let progressMin = 0.1
    let searchPath = "https://www.google.co.jp/search?q="
    let defaultUrlKey = "defaultUrl"
    let locationIndexKey = "locationIndex"
    let historySavableTermKey = "historySaveblaTerm"
    let appFont = "Avenir"
    let eachHistoryPath = URL(fileURLWithPath: DeviceDataManager.shared.documentsDir + "/each_history.dat")
    
    private init() {
        
    }
    
    func commonHistoryPath(date: String) -> URL {
        return URL(fileURLWithPath: DeviceDataManager.shared.documentsDir + "/\(date).dat")
    }
    
    func registerDefaultData() {
        UserDefaults.standard.register(defaults: [defaultUrlKey: "https://amazon.co.jp",
                                                  locationIndexKey: 0,
                                                  historySavableTermKey: 10])
    }
}
