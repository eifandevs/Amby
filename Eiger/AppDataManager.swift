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
    let defaultUrlKey = "default-url"
    let historySavableTermKey = "history-savebla-term"
    
    private init() {
        
    }
    
    public func registerDefaultData() {
        UserDefaults.standard.register(defaults: [defaultUrlKey: "https://google.com",
                                                  historySavableTermKey: 10])
    }
}
