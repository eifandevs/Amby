//
//  PostFavoriteRequest.swift
//  Entity
//
//  Created by tenma.i on 2019/12/19.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

/// フォーム登録リクエスト
public struct PostFormRequest {
    public init(userId: String, forms: [Form]) {
        self.userId = userId
        self.forms = forms
    }

    public let userId: String
    public let forms: [Form]
}
