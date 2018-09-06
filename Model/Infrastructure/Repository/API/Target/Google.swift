//
//  Google.swift
//  Qas
//
//  Created by tenma on 2018/03/19.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation
import Moya

public enum Google {
    case suggest(token: String)
}

extension Google: TargetType {
    // ベースのURL
    public var baseURL: URL { return URL(string: ModelHttpConst.URL.SUGGEST_SERVER_DOMAIN)! }

    // パス
    public var path: String {
        switch self {
        case .suggest:
            return ModelHttpConst.URL.SUGGEST_SERVER_PATH
        }
    }

    // HTTPメソッド
    public var method: Moya.Method {
        switch self {
        case .suggest:
            return .get
        }
    }

    // スタブデータ
    public var sampleData: Data {
        let path = { () -> String in
            switch self {
            case .suggest:
                return Bundle.main.path(forResource: "suggest_stub", ofType: "json")!
            }
        }()
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }

    // リクエストパラメータ等
    public var task: Task {
        switch self {
        case let .suggest(token):
            return .requestParameters(parameters: ["hl": "en", "client": "firefox", "q": token], encoding: URLEncoding.default)
        }
    }

    // ヘッダー
    public var headers: [String: String]? {
        return nil
    }
}
