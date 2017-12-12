//
//  ApiRequest.swift
//  Qas
//
//  Created by temma on 2017/12/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Alamofire

struct ApiRequest {
    // リクエストパス
    var path: String
    // リクエストパラメータ
    var parameters: Parameters?
}
