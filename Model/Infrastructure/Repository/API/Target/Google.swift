//
//  Google.swift
//  Qas
//
//  Created by tenma on 2018/03/19.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation
import Moya

enum Google {
    case suggest(token: String)
}

extension Google: TargetType {
    // ベースのURL
    var baseURL: URL { return URL(string: ModelConst.URL.SUGGEST_SERVER_DOMAIN)! }

    // パス
    var path: String {
        switch self {
        case .suggest:
            return ModelConst.URL.SUGGEST_SERVER_PATH
        }
    }

    // HTTPメソッド
    var method: Moya.Method {
        switch self {
        case .suggest:
            return .get
        }
    }

    // スタブデータ
    var sampleData: Data {
        let path = { () -> String in
            switch self {
            case .suggest:
                return Bundle.main.path(forResource: "suggest_stub", ofType: "json")!
            }
        }()
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }

    // リクエストパラメータ等
    var task: Task {
        switch self {
        case let .suggest(token):
            return .requestParameters(parameters: ["hl": "en", "client": "firefox", "q": token], encoding: URLEncoding.default)
        }
    }

    // ヘッダー
    var headers: [String: String]? {
        return nil
    }
}
