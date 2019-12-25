//
//  PostFavoriteRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/12/19.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// メモ登録リクエスト
public struct PostMemoRequest {
    public init(userId: String, memos: [Memo]) {
        self.userId = userId
        self.memos = memos
    }

    public let userId: String
    public let memos: [Memo]
}
