//
//  ArticleResponse.swift
//  Qas
//
//  Created by tenma on 2018/04/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

/// 記事取得APIレスポンス
struct ArticleResponse: Codable {
    init(code: String, data: [Article]) {
        self.code = code
        self.data = data
    }

    let code: String
    let data: [Article]
}
