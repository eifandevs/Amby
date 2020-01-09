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
    case login(request: LoginRequest)
    case getArticle(request: GetArticleRequest)
    case getFavorite(request: GetFavoriteRequest)
    case getAccessToken(request: GetAccessTokenRequest)
    case getMemo(request: GetMemoRequest)
    case getTabData(request: GetTabRequest)
    case getForm(request: GetFormRequest)
    case postFavorite(request: PostFavoriteRequest)
    case postForm(request: PostFormRequest)
}

extension App: TargetType {
    // ベースのURL
    var baseURL: URL { return URL(string: ModelConst.URL.APP_SERVER_DOMAIN)! }

    // パス
    var path: String {
        switch self {
        case .login:
            return ModelConst.URL.LOGIN_API_PATH
        case .getArticle:
            return ModelConst.URL.ARTICLE_API_PATH
        case .getFavorite, .postFavorite:
            return ModelConst.URL.FAVORITE_API_PATH
        case .getAccessToken:
            return ModelConst.URL.ACCESSTOKEN_API_PATH
        case .getMemo:
            return ModelConst.URL.MEMO_API_PATH
        case .getTabData:
            return ModelConst.URL.TAB_API_PATH
        case .getForm, .postForm:
            return ModelConst.URL.FORM_API_PATH
        }
    }

    // HTTPメソッド
    var method: Moya.Method {
        switch self {
        case .login, .postFavorite, .postForm:
            return .post
        case .getArticle:
            return .get
        case .getFavorite:
            return .get
        case .getAccessToken:
            return .get
        case .getMemo:
            return .get
        case .getTabData:
            return .get
        case .getForm:
            return .get
        }
    }

    // スタブデータ
    var sampleData: Data {
        let path = { () -> String in
            switch self {
            case .login:
                return Bundle.main.path(forResource: "login_stub", ofType: "json")!
            case .getArticle:
                return Bundle.main.path(forResource: "article_stub", ofType: "json")!
            case .getFavorite:
                return Bundle.main.path(forResource: "favorite_stub", ofType: "json")!
            case .getAccessToken:
                return Bundle.main.path(forResource: "accesstoken_stub", ofType: "json")!
            case .getMemo:
                return Bundle.main.path(forResource: "memo_stub", ofType: "json")!
            case .getTabData:
                return Bundle.main.path(forResource: "tab_stub", ofType: "json")!
            case .getForm:
                return Bundle.main.path(forResource: "form_stub", ofType: "json")!
            case .postFavorite:
                return Bundle.main.path(forResource: "post_favorite_stub", ofType: "json")!
            case .postForm:
                return Bundle.main.path(forResource: "post_form_stub", ofType: "json")!
        }
        }()
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }

    // リクエストパラメータ等
    var task: Task {
        switch self {
        case .login:
            return .requestPlain
        case .getArticle:
            return .requestPlain
        case .getFavorite:
            return .requestPlain
        case .getAccessToken:
            return .requestPlain
        case .getMemo:
            return .requestPlain
        case .getTabData:
            return .requestPlain
        case .getForm:
            return .requestPlain
        case let .postFavorite(request):
            return .requestParameters(parameters: ["favorites": request.favorites], encoding: URLEncoding.default)
        case let .postForm(request):
            return .requestParameters(parameters: ["forms": request.forms], encoding: URLEncoding.default)
        }
    }

    // ヘッダー
    var headers: [String: String]? {
        switch self {
        case let .login(request):
            return ["AccessToken": "aaa", "UserRawToken": request.userId]
        case .getArticle:
            return ["AccessToken": "aaa", "UserToken": "aaa"]
        case .getFavorite, .postFavorite:
            return ["AccessToken": "aaa", "UserToken": "aaa"]
        case .getAccessToken:
            return nil
        case .getMemo:
            return ["AccessToken": "aaa", "UserToken": "aaa"]
        case .getTabData:
            return ["AccessToken": "aaa", "UserToken": "aaa"]
        case .getForm, .postForm:
            return ["AccessToken": "aaa", "UserToken": "aaa"]
        }
    }
}
