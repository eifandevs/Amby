//
//  GetFavoriteResponse.swift
//  Entity
//
//  Created by tenma.i on 2019/08/20.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// お気に入り取得APIレスポンス
public struct GetFavoriteResponse: Codable {

    public struct Favorite: Codable {
        public var id: String
        public var title: String
        public var url: String
    }

    public init(code: String, data: [GetFavoriteResponse.Favorite]) {
        self.code = code
        self.data = data
    }

    public let code: String
    public let data: [GetFavoriteResponse.Favorite]
}
