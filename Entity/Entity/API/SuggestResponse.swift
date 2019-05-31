//
//  SuggestResponse.swift
//  Amby
//
//  Created by tenma on 2018/03/21.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation

/// サジェストAPIレスポンス
public struct SuggestResponse {
    public init(data: [Any]) {
        self.data = data
    }

    // レスポンスがjsonではないので、codableを使用せず、マニュアルでマッピングする
    public let data: [Any]
}
