//
//  GetAccessTokenRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/08/16.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// トークン取得リクエスト
public struct GetAccessTokenRequest {

    public init(auth_type: Int, email: String?) {
        self.auth_type = auth_type
        self.email = email
    }

    public let auth_type: Int // 1: 共通, 2: Google
    public let email: String?
}
