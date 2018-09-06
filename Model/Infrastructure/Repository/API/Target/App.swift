//
//  App.swift
//  Qas
//
//  Created by tenma on 2018/04/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Moya

public enum App {
    case article
}

extension App: TargetType {
    // ベースのURL
    public var baseURL: URL { return URL(string: ModelHttpConst.URL.APP_SERVER_DOMAIN)! }

    // パス
    public var path: String {
        switch self {
        case .article:
            return ModelHttpConst.URL.APP_SERVER_PATH
        }
    }

    // HTTPメソッド
    public var method: Moya.Method {
        switch self {
        case .article:
            return .get
        }
    }

    // スタブデータ
    public var sampleData: Data {
        let path = { () -> String in
            switch self {
            case .article:
                return Bundle.main.path(forResource: "article_stub", ofType: "json")!
            }
        }()
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }

    // リクエストパラメータ等
    public var task: Task {
        switch self {
        case .article:
            return .requestPlain
        }
    }

    // ヘッダー
    public var headers: [String: String]? {
        switch self {
        case .article:
            return nil
        }
    }
}
