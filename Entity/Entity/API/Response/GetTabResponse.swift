//
//  GetTabResponse.swift
//  Entity
//
//  Created by tenma.i on 2019/11/29.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// タブ取得APIレスポンス
public struct GetTabResponse: Codable {

    public init(code: String, data: TabGroupList) {
        self.code = code
        self.data = data
    }

    public let code: String
    public let data: TabGroupList
}
