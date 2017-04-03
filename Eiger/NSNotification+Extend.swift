//
//  NSNotification+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/03/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let baseViewDidLoad = NSNotification.Name("baseViewDidLoad")
    static let baseViewDidAddWebView = NSNotification.Name("baseViewDidAddWebView")
    static let baseViewDidRemoveWebView = NSNotification.Name("baseViewDidRemoveWebView")
    static let baseViewDidChangeWebView = NSNotification.Name("baseViewDidChangeWebView")
    static let baseViewDidStartLoading = NSNotification.Name("baseViewDidStartLoading")
    static let baseViewDidEndLoading = NSNotification.Name("baseViewDidEndLoading")
}
