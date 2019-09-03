//
//  GetArticleResponse.swift
//  Amby
//
//  Created by tenma on 2018/04/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

/// 記事取得APIレスポンス
public struct GetArticleResponse: Codable {

    public struct Article: Codable {
        public var id: Int?
        public var source_name: String?
        public var author: String?
        public var title: String?
        public var description: String?
        public var url: String?
        public var image_url: String?
        public var published_time: String?
        public var created_at: String?
        public var updated_at: String?
        public var next_update: String?
    }

    public init(code: String, data: [Article]) {
        self.code = code
        self.data = data
    }

    public let code: String
    public let data: [Article]
}
