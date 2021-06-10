//
//  GetFormResponse.swift
//  Entity
//
//  Created by tenma.i on 2019/12/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// フォーム取得APIレスポンス
public struct GetFormResponse: Codable {

    public init(code: String, data: [Form]) {
        self.code = code
        self.data = data
    }

    public let code: String
    public let data: [Form]
}
