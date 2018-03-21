//
//  HttpConst.swift
//  Qas
//
//  Created by temma on 2017/08/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

final class HttpConst {
    static let SUGGEST_SERVER_DOMAIN = "https://www.google.com"
    static let SUGGEST_SERVER_PATH = "/complete/search?hl=en&client=firefox&q="
}

/// APIリザルト(ApiClientのレスポンス)
enum ApiResult {
    case success(ApiResponse)
    case failure(ApiResponse)
}

/// リザルト(各Modelクラスのレスポンス)
enum Result<T> {
    case success(T)
    case failure(ApiResponse)
}
