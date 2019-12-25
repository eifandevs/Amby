//
//  PostFavoriteRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/12/19.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// タブ登録リクエスト
public struct PostTabRequest {
    public init(userId: String, tabGroupList: TabGroupList) {
        self.userId = userId
        self.tabGroupList = tabGroupList
    }

    public let userId: String
    public let tabGroupList: TabGroupList
}
