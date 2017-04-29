//
//  NSNotification+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/03/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let baseViewAddWebView = NSNotification.Name("baseViewAddWebView")
    static let baseViewRemoveWebView = NSNotification.Name("baseViewRemoveWebView")
    static let baseViewChangeWebView = NSNotification.Name("baseViewChangeWebView")
    static let footerViewLoad = NSNotification.Name("footerViewLoad")
    static let footerViewAddWebView = NSNotification.Name("footerViewAddWebView")
    static let footerViewRemoveWebView = NSNotification.Name("footerViewRemoveWebView")
    static let footerViewChangeWebView = NSNotification.Name("footerViewChangeWebView")
    static let footerViewStartLoading = NSNotification.Name("footerViewStartLoading")
    static let footerViewEndLoading = NSNotification.Name("footerViewEndLoading")
}
