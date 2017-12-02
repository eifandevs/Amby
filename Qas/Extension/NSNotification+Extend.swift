//
//  NSNotification+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/03/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    // View
    static let baseViewControllerWillPresentHelp = NSNotification.Name("baseViewControllerWillPresentHelp")
    // ViewModel
    static let headerViewModelWillChangeProgress = NSNotification.Name("headerViewModelWillChangeProgress")
    static let headerViewModelWillChangeField = NSNotification.Name("headerViewModelWillChangeField")
    static let headerViewModelWillChangeFavorite = NSNotification.Name("headerViewModelWillChangeFavorite")
    static let headerViewModelWillBeginEditing = NSNotification.Name("headerViewModelWillBeginEditing")
    static let baseViewModelWillAutoInput = NSNotification.Name("baseViewModelWillAutoInput")
    static let baseViewModelWillCopyWebView = NSNotification.Name("baseViewModelWillCopyWebView")
    static let baseViewModelWillReloadWebView = NSNotification.Name("baseViewModelWillReloadWebView")
    static let baseViewModelWillStoreHistory = NSNotification.Name("baseViewModelWillStoreHistory")
    static let baseViewModelWillRemoveWebView = NSNotification.Name("baseViewModelWillRemoveWebView")
    static let baseViewModelWillHistoryBackWebView = NSNotification.Name("baseViewModelWillHistoryBackWebView")
    static let baseViewModelWillDeleteHistory = NSNotification.Name("baseViewModelWillDeleteHistory")
    static let baseViewModelWillInitialize = NSNotification.Name("baseViewModelWillInitialize")
    static let baseViewModelWillHistoryForwardWebView = NSNotification.Name("baseViewModelWillHistoryForwardWebView")
    static let baseViewModelWillCopyUrl = NSNotification.Name("baseViewModelWillCopyUrl")
    static let baseViewModelWillSearchWebView = NSNotification.Name("baseViewModelWillSearchWebView")
    static let baseViewModelWillChangeFavorite = NSNotification.Name("baseViewModelWillChangeFavorite")
    static let baseViewModelWillRegisterAsFavorite = NSNotification.Name("baseViewModelWillRegisterAsFavorite")
    static let baseViewModelWillRegisterAsForm = NSNotification.Name("baseViewModelWillRegisterAsForm")
    static let baseViewModelWillAutoScroll = NSNotification.Name("baseViewModelWillAutoScroll")
    static let searchMenuTableViewModelWillUpdateSearchToken = NSNotification.Name("searchMenuTableViewModelWillUpdateSearchToken")
    static let footerViewModelWillLoad = NSNotification.Name("footerViewModelWillLoad")
    static let footerViewModelWillAddWebView = NSNotification.Name("footerViewModelWillAddWebView")
    static let footerViewModelWillRemoveWebView = NSNotification.Name("footerViewModelWillRemoveWebView")
    static let footerViewModelWillChangeWebView = NSNotification.Name("footerViewModelWillChangeWebView")
    static let footerViewModelWillStartLoading = NSNotification.Name("footerViewModelWillStartLoading")
    static let footerViewModelWillEndLoading = NSNotification.Name("footerViewModelWillEndLoading")
    // Model
    static let pageHistoryDataModelDidRemove = NSNotification.Name("pageHistoryDataModelDidRemove")
    static let pageHistoryDataModelDidInsert = NSNotification.Name("pageHistoryDataModelDidInsert")
    static let pageHistoryDataModelDidChange = NSNotification.Name("pageHistoryDataModelDidChange")
    static let pageHistoryDataModelDidStartLoading = NSNotification.Name("pageHistoryDataModelDidStartLoading")
    static let pageHistoryDataModelDidEndLoading = NSNotification.Name("pageHistoryDataModelDidEndLoading")
}
