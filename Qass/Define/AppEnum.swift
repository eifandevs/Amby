//
//  AppEnum.swift
//  Qass
//
//  Created by tenma on 2018/11/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

enum Result<T, Error> {
    case success(T)
    case failed(Error)
}
