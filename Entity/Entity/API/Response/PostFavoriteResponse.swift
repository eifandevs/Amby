//
//  PostFavoriteResponse.swift
//  Entity
//
//  Created by tenma.i on 2019/12/25.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// お気に入り登録APIレスポンス
public struct PostFavoriteResponse: Codable {

    public init(code: String) {
        self.code = code
    }

    public let code: String
}
