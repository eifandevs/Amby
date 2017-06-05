//
//  NSNotification+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/03/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let headerViewModelWillChangeProgress = NSNotification.Name("headerViewModelWillChangeProgress")
    static let headerViewModelWillChangeField = NSNotification.Name("headerViewModelWillChangeField")
    static let baseViewModelWillAddWebView = NSNotification.Name("baseViewModelWillAddWebView")
    static let baseViewModelWillReloadWebView = NSNotification.Name("baseViewModelWillReloadWebView")
    static let baseViewModelWillRemoveWebView = NSNotification.Name("baseViewModelWillRemoveWebView")
    static let baseViewModelWillChangeWebView = NSNotification.Name("baseViewModelWillChangeWebView")
    static let baseViewModelWillHistoryBackWebView = NSNotification.Name("baseViewModelWillHistoryBackWebView")
    static let baseViewModelWillHistoryForwardWebView = NSNotification.Name("baseViewModelWillHistoryForwardWebView")
    static let baseViewModelWillSearchWebView = NSNotification.Name("baseViewModelWillSearchWebView")
    static let baseViewModelWillRegisterAsFavorite = NSNotification.Name("baseViewModelWillRegisterAsFavorite")
    static let baseViewModelWillRegisterAsForm = NSNotification.Name("baseViewModelWillRegisterAsForm")
    static let baseViewModelWillAutoScroll = NSNotification.Name("baseViewModelWillAutoScroll")
    static let footerViewModelWillLoad = NSNotification.Name("footerViewModelWillLoad")
    static let footerViewModelWillAddWebView = NSNotification.Name("footerViewModelWillAddWebView")
    static let footerViewModelWillRemoveWebView = NSNotification.Name("footerViewModelWillRemoveWebView")
    static let footerViewModelWillChangeWebView = NSNotification.Name("footerViewModelWillChangeWebView")
    static let footerViewModelWillStartLoading = NSNotification.Name("footerViewModelWillStartLoading")
    static let footerViewModelWillEndLoading = NSNotification.Name("footerViewModelWillEndLoading")
}
