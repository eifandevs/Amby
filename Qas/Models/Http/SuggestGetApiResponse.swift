//
//  SuggestGetApiResponse.swift
//  Qas
//
//  Created by temma on 2017/08/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class SuggestGetApiResponse {
    var data: [String] = []
    
    init(response: Dictionary<String, Any>) {
        mapping(response: response)
    }
    
    private func mapping(response: Dictionary<String, Any>) {
        data = (response["result"] as! [Any])[1] as! [String]
    }
}
