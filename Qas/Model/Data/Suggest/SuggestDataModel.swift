//
//  SuggestDataModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Alamofire

final class SuggestDataModel {
    static func fetch(token: String, completion: ((Suggest?) -> ())?) {
        let api = ApiClient(url: HttpConst.HTTP_SERVER_DOMAIN + HttpConst.HTTP_SERVER_PATH + token)
        api.get(success: { (json: Dictionary) in
            let data = (json["result"] as? [Any] ?? [String]())[safe: 1] as? [String] ?? [String]()
            completion?(Suggest(data: data))
        }) { (error: Error?) in
            completion?(nil)
        }
    }
}
