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

    /// resource repository
    let repository = ResourceRepository()

    func get(key: String) -> String {
        return repository.envList[key] as! String
    }
}
