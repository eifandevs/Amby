//
//  ApiResponse.swift
//  Qas
//
//  Created by temma on 2017/12/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Alamofire

struct ApiResponse {
    // リクエストURL
    var url: String
    // リクエストパラメータ
    var parameter: Parameters?
    // レスポンス
    var response: (data: Data?, code: Int, msg: String)?
    // エラー情報
    var error: Error?
    // HTTPステータスコード
    var code: Int?
}
