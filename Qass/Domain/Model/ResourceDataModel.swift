//
//  ResourceDataModel.swift
//  Qass
//
//  Created by tenma on 2018/06/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class ResourceDataModel {
    static let s = ResourceDataModel()

    /// timeout page
    var timeoutHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }

    /// dns error page
    var dnsHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }

    /// offline error page
    var offlineHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }

    /// authorize error page
    var authorizeHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }

    /// common error page
    var invalidHtml: Foundation.URL {
        return ResourceRepository().timeoutHtml
    }

    /// highlight js
    var highlightScript: Foundation.URL {
        return ResourceRepository().highlightScript
    }

    private init() {}

}
