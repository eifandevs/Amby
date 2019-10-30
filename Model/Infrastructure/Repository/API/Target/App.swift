//
//  App.swift
//  Amby
//
//  Created by tenma on 2018/04/16.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Entity
import Moya

enum App {
    case article
    case favorite
    case accessToken(request: GetAccessTokenRequest)
}

extension App: TargetType {
    // ベースのURL
    var baseURL: URL { return URL(string: ModelConst.URL.APP_SERVER_DOMAIN)! }

    // パス
    var path: String {
        switch self {
        case .article:
            return ModelConst.URL.ARTICLE_API_PATH
        case .favorite:
            return ModelConst.URL.FAVORITE_API_PATH
        case .accessToken:
            return ModelConst.URL.ACCESSTOKEN_API_PATH
        }
    }

    // HTTPメソッド
    var method: Moya.Method {
        switch self {
        case .article:
            return .get
        case .favorite:
            return .get
        case .accessToken:
            return .get
        }
    }

    // スタブデータ
    var sampleData: Data {
        let path = { () -> String in
            switch self {
            case .article:
                return Bundle.main.path(forResource: "article_stub", ofType: "json")!
            case .favorite:
                return Bundle.main.path(forResource: "favorite_stub", ofType: "json")!
            case .accessToken:
            return Bundle.main.path(forResource: "accesstoken_stub", ofType: "json")!
        }
        }()
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }

    // リクエストパラメータ等
    var task: Task {
        switch self {
        case .article:
            return .requestPlain
        case .favorite:
            return .requestPlain
        case .accessToken:
            return .requestPlain
        }
    }

    // ヘッダー
    var headers: [String: String]? {
        switch self {
        case .article:
            return nil
        case .favorite:
            return nil
        case let .accessToken(request):
            return ["X-Auth-Token": request.authHeaderToken]
        }
    }
}
