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

    public init(authHeaderToken: String) {
        self.authHeaderToken = authHeaderToken
    }

    public let authHeaderToken: String
}
