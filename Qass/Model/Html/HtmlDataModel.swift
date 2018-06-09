//
//  HtmlDataModel.swift
//  Qass
//
//  Created by tenma on 2018/06/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class HtmlDataModel {
    static let s = HtmlDataModel()
    
    /// タイムアウトページ
    var timeoutHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }
    
    /// DNSエラーページ
    var dnsHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }
    
    /// オフラインエラーページ
    var offlineHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }
    
    /// 認証エラーページ
    var authorizeHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }
    
    /// 汎用エラーページ
    var invalidHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }
}
