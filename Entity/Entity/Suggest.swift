//
//  Suggest.swift
//  Amby
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

public struct Suggest {
    public var token: String
    public var data: [String]?

    public init(token: String, data: [String]?) {
        self.token = token
        self.data = data
    }
}
