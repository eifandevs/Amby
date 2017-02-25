//
//  AppDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class AppDataManager {
    static let shared: AppDataManager = AppDataManager()
    let defaultUrlKey = "defaultUrl"
    let locationIndexKey = "locationIndex"
    let historySavableTermKey = "historySaveblaTerm"
    let eachHistoryPath = URL(fileURLWithPath: DeviceDataManager.shared.documentsDir + "/tab_history.dat")
    let commonHistoryPath = URL(fileURLWithPath: DeviceDataManager.shared.documentsDir + "/common_history.dat")

    private init() {
        
    }
    
    public func registerDefaultData() {
        UserDefaults.standard.register(defaults: [defaultUrlKey: "https://google.com",
                                                  locationIndexKey: 0,
                                                  historySavableTermKey: 10])
    }
}
