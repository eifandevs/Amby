//
//  EnvDataModel.swift
//  Qass
//
//  Created by tenma on 2018/05/30.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class EnvDataModel {
    static let s = EnvDataModel()

    func get(key: String) -> String {
        #if PRODUCTION
            let domainPath = Bundle.main.path(forResource: "env", ofType: "plist")
            let plist = NSDictionary(contentsOfFile: domainPath!)
            return plist?[key] as! String
        #else
            let domainPath = Bundle.main.path(forResource: "env-dev", ofType: "plist")
            let plist = NSDictionary(contentsOfFile: domainPath!)
            return plist?[key] as! String
        #endif
    }
}
