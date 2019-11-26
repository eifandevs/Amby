//
//  GetTabRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/11/26.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// タブ情報リクエスト
public struct GetTabRequest {
    public init(userId: String) {
        self.userId = userId
    }

    public let userId: String
}
