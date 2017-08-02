//
//  ApiManager.swift
//  Qas
//
//  Created by temma on 2017/08/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Alamofire

class ApiManager {
    let url: String
    let method: HTTPMethod
    let parameters: Parameters?
    
    init(url: String, method: HTTPMethod = .get, parameters: Parameters? = nil) {
        self.url = url
        self.method = method
        self.parameters = parameters
    }
    
    func request(success: @escaping (_ data: Dictionary<String, Any>)-> Void, fail: @escaping (_ error: Error?)-> Void) {
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
}
