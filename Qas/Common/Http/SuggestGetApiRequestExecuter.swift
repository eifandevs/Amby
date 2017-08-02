//
//  SuggestGetApiRequestExecuter.swift
//  Qas
//
//  Created by temma on 2017/08/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Alamofire

class SuggestGetAPIRequestExecuter {
    static func request(token: String, completion: ((SuggestGetApiResponse?) -> ())?) {
        let api = ApiManager(url: HttpConst.suggestApiUrl + token)
        api.request(success: { (json: Dictionary) in
            completion?(SuggestGetApiResponse(response: json))
        }) { (error: Error?) in
            completion?(nil)
        }
    }
}
