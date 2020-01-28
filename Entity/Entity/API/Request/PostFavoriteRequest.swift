//
//  PostFavoriteRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/12/19.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// お気に入り登録リクエスト
public struct PostFavoriteRequest {
    public init(userId: String, favorites: [Favorite]) {
        self.userId = userId
        self.favorites = favorites
    }

    public let userId: String
    public let favorites: [Favorite]
}
