//
//  ApiClient.swift
//  Qas
//
//  Created by temma on 2017/08/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Alamofire

class ApiClient {
    let url: String
    let method: HTTPMethod
    let parameters: Parameters?
    
    init(url: String, method: HTTPMethod = .get, parameters: Parameters? = nil) {
        self.url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        self.method = method
        self.parameters = parameters
    }
    
    func get(success: @escaping (_ data: Dictionary<String, Any>)-> Void, fail: @escaping (_ error: Error?)-> Void) {
        Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                let json = ["result": response.result.value ?? ""]
                log.debug("http req success. [url, responst]=[\(self.url), \(json)]")
                success(json)
            } else {
                log.error("http req faild. [url, response, error]=[\(self.url), \(String(describing: response.result.value)), \(String(describing: response.result.error?.localizedDescription))]")
                fail(response.result.error)
            }
        }
    }

//    /// Http-Postメソッド
//    /// マルチパートデータで送信する
//    func post(request: ApiRequest, completion: @escaping (ApiResult)-> Void) {
//        let url = (domain + request.path).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            // リクエストパラメータをパート別に分ける
//            request.parameters?.forEach({ (arg0) in
//                let (key, value) = arg0
//                if let data = (value as? String ?? String(describing: value)).data(using: String.Encoding.utf8) {
//                    multipartFormData.append(data, withName: key)
//                }
//            })
//        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (encodingResult) in
//            switch encodingResult {
//            case .success(let upload, _, _):
//                upload.responseJSON(completionHandler: { (response) in
//                    completion(self.createApiResult(request: request, response: response))
//                })
//            case .failure(let error):
//                log.error("api req faild, response encoding error. \n[\n url: \(url)\n parameter: \(String(describing: request.parameters ?? nil))\n httpStatusCode:\n appStatusCode:\n response:\n error: \(String(describing: error.localizedDescription))\n]")
//                let res = ApiResponse(url: url, parameter: request.parameters, response: nil, error: error, code: nil)
//                completion(ApiResult.failure(res))
//            }
//        }
//    }
//
//    /// Http-Getメソッド
//    func get(request: ApiRequest, completion: @escaping (ApiResult)-> Void) {
//        let url = (domain + request.path).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//
//        // Getパラメータは、クエリで送信する
//        Alamofire.request(url, method: .get, parameters: request.parameters, encoding: URLEncoding(destination: .queryString), headers: headers).responseJSON { [weak self] response in
//            guard let `self` = self else { return }
//            completion(self.createApiResult(request: request, response: response))
//        }
//    }
//
//    /// APIリザルト作成
//    func createApiResult(request: ApiRequest, response: DataResponse<Any>) -> ApiResult {
//        // リクエストURL
//        let url = (domain + request.path).addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//
//        // HTTPステータスコード
//        let httpStatusCode = response.response?.statusCode
//
//        // レスポンスが存在するか確認
//        if let rawJson = response.result.value {
//            let json = rawJson as! Dictionary<String, Any>
//
//            // 必須パラメータ確認
//            if let status = json[HttpConst.JSON_STATUS], let _ = json[HttpConst.JSON_RESULT], let statusCode = (status as! Dictionary<String, Any>)[HttpConst.JSON_CODE] {
//                // APPステータスコード
//                let appStatusCode = Int(statusCode as! String)!
//
//                // レスポンスマッピング
//                let result = (data: response.data, code: appStatusCode, msg: (json[HttpConst.JSON_MESSAGE] ?? "") as! String)
//                let res = ApiResponse(url: url, parameter: request.parameters, response: result, error: response.result.error, code: httpStatusCode)
//
//                // HTTPステータスコードの確認
//                if httpStatusCode != HttpConst.HTTP_STATUS_CODE_NORMAL {
//                    log.error("api req failed, http status code error. \n[\n url: \(url)\n parameter: \(String(describing: request.parameters ?? nil))\n httpStatusCode: \(httpStatusCode ?? 0)\n appStatusCode: \(appStatusCode)\n response: \(json)\n error: \(String(describing: response.result.error?.localizedDescription))\n]")
//                    return ApiResult.failure(res)
//                }
//
//                // APPステータスコードの確認
//                if appStatusCode == HttpConst.APP_STATUS_CODE_NORMAL {
//                    log.debug("api req success. \n[\n url: \(url)\n parameter: \(String(describing: request.parameters ?? nil))\n httpStatusCode: \(httpStatusCode ?? 0)\n appStatusCode: \(appStatusCode)\n response: \(json)\n error: \(String(describing: response.result.error?.localizedDescription))\n]")
//                    return ApiResult.success(res)
//                } else {
//                    log.error("api req failed, app status code error. \n[\n url: \(url)\n parameter: \(String(describing: request.parameters ?? nil))\n httpStatusCode: \(httpStatusCode ?? 0)\n appStatusCode: \(appStatusCode)\n response: \(json)\n error: \(String(describing: response.result.error?.localizedDescription))\n]")
//                    return ApiResult.failure(res)
//                }
//            } else {
//                log.error("api req faild, api required parameter not found. \n[\n url: \(url)\n parameter: \(String(describing: request.parameters ?? nil))\n httpStatusCode: \(httpStatusCode ?? 0)\n appStatusCode:\n response: \(json)\n error: \(String(describing: response.result.error?.localizedDescription))\n]")
//                let res = ApiResponse(url: url, parameter: request.parameters, response: nil, error: response.result.error, code: httpStatusCode)
//                return ApiResult.failure(res)
//            }
//        } else {
//            log.error("api req faild, response not found. \n[\n url: \(url)\n parameter: \(String(describing: request.parameters ?? nil))\n httpStatusCode: \(httpStatusCode ?? 0)\n appStatusCode:\n response:\n error: \(String(describing: response.result.error?.localizedDescription))\n]")
//            let res = ApiResponse(url: url, parameter: request.parameters, response: nil, error: response.result.error, code: httpStatusCode)
//            return ApiResult.failure(res)
//        }
//    }
}
