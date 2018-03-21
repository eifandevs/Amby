//
//  ApiTarget.swift
//  Qas
//
//  Created by tenma on 2018/03/19.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation
import Moya

enum Common {
    case suggest(token: String)
}

extension Common: TargetType {
    // ベースのURL
    var baseURL: URL {
        switch self {
        case .suggest:
            return URL(string: HttpConst.SUGGEST_SERVER_DOMAIN)!
        }
    }
    
    // パス
    var path: String {
        switch self {
        case .suggest:
            return HttpConst.SUGGEST_SERVER_PATH
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
        case .suggest(let token):
            return .requestParameters(parameters: ["token": token], encoding: URLEncoding.default)
        }
    }
    
    // ヘッダー
    var headers: [String: String]? {
        return nil
    }
}
