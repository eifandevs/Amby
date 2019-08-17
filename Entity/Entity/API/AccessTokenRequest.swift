//
//  AccessTokenRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/08/16.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// トークン取得リクエスト
public struct AccessTokenRequest {

    public init(auth_type: Int, email: String?, refresh_token: String?) {
        self.auth_type = auth_type
        self.email = email
        self.refresh_token = refresh_token
    }

    public let auth_type: Int // 1: 共通, 2: Google
    public let email: String?
    public let refresh_token: String?
}
