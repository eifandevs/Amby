//
//  SuggestResponse.swift
//  Qas
//
//  Created by tenma on 2018/03/21.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation

/// サジェストAPIレスポンス
struct SuggestResponse {
    init(data: [Any]) {
        self.data = data
    }

    // レスポンスがjsonではないので、codableを使用せず、マニュアルでマッピングする
    let data: [Any]
}
