//
//  LoginRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/10/31.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// トークン取得リクエスト
public struct LoginRequest {

    public init(userId: String) {
        self.userId = userId
    }

    public let userId: String
}
