//
//  GetMemoResponse.swift
//  Entity
//
//  Created by iori tenma on 2019/08/25.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

public struct GetMemoResponse: Codable {

    public struct Memo: Codable {
        public var id: String
        public var text: String
        public var isLocked: Bool
    }

    public init(code: String, data: [Memo]) {
        self.code = code
        self.data = data
    }

    public let code: String
    public let data: [Memo]
}
