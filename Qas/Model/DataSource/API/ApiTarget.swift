//
//  ApiTarget.swift
//  Qas
//
//  Created by tenma on 2018/03/19.
//  Copyright © 2018年 eifaniori. All rights reserved.
//

import Foundation
import Moya

enum ApiTarget {
    // パスごとにcaseを切り分ける
    case suggest(token: String)
}

extension ApiTarget: TargetType {
    // ベースのURL
    var baseURL: URL {
        return URL(string: "https://hogehoge.com")!
    }
    
    // パス
    var path: String {
        switch self {
        case .suggest:
            return "/login"
        }
    }
    
    // HTTPメソッド
    var method: Moya.Method {
        switch self {
        case .suggest:
            return .post
        }
    }
    
    // スタブデータ
    var sampleData: Data {
        let path = Bundle.main.path(forResource: "suggest_stub", ofType: "json")!
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }
    
    // リクエストパラメータ等
    var task: Task {
        switch self {
        case .suggest(let token):
            return .requestParameters(parameters: ["token" : token], encoding: URLEncoding.default)
        }
    }
    
    // ヘッダー
    var headers: [String: String]? {
        return nil
    }
}
