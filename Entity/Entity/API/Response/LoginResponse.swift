//
//  LoginResponse.swift
//  Entity
//
//  Created by tenma.i on 2019/10/31.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// ログインレスポンス
public struct LoginResponse: Codable {

    public struct UserInfo: Codable {
        public var userId: String
    }

    public init(code: String, data: UserInfo) {
        self.code = code
        self.data = data
    }

    public let code: String
    public let data: UserInfo
}
