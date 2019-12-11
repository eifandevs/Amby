//
//  GetFormRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/12/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// フォーム取得リクエスト
public struct GetFormRequest {
    public init(userId: String) {
        self.userId = userId
    }

    public let userId: String
}
