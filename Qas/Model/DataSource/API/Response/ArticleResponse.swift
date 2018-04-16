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
    // レスポンスがjsonではないので、codableを使用せず、マニュアルでマッピングする
    let code: String
    let articles: [Article]
}
