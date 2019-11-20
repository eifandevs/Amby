//
//  GetMemoRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/11/20.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// メモ取得リクエスト
public struct GetMemoRequest {
    public init(userId: String) {
        self.userId = userId
    }

    public let userId: String
}
