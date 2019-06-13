//
//  ArticleResponse.swift
//  Amby
//
//  Created by tenma on 2018/04/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

/// 記事取得APIレスポンス
public struct ArticleResponse: Codable {
    public init(code: String, data: [Article]) {
        self.code = code
        self.data = data
    }

    public let code: String
    public let data: [Article]
}
