//
//  NSNotification+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/03/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    // MARK: - View
    static let baseViewControllerWillPresentHelp = NSNotification.Name("baseViewControllerWillPresentHelp")
    // MARK: - ViewModel
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
    static let baseViewModelWillRegisterAsFavorite = NSNotification.Name("baseViewModelWillRegisterAsFavorite")
    static let baseViewModelWillRegisterAsForm = NSNotification.Name("baseViewModelWillRegisterAsForm")
    static let baseViewModelWillAutoScroll = NSNotification.Name("baseViewModelWillAutoScroll")
    static let searchMenuTableViewModelWillUpdateSearchToken = NSNotification.Name("searchMenuTableViewModelWillUpdateSearchToken")
    static let footerViewModelWillRemoveWebView = NSNotification.Name("footerViewModelWillRemoveWebView")
    // MARK: - Model
    // PageHistoryDataModel
    static let pageHistoryDataModelDidRemove = NSNotification.Name("pageHistoryDataModelDidRemove")
    static let pageHistoryDataModelDidInsert = NSNotification.Name("pageHistoryDataModelDidInsert")
    static let pageHistoryDataModelDidChange = NSNotification.Name("pageHistoryDataModelDidChange")
    static let pageHistoryDataModelDidStartLoading = NSNotification.Name("pageHistoryDataModelDidStartLoading")
    static let pageHistoryDataModelDidEndLoading = NSNotification.Name("pageHistoryDataModelDidEndLoading")
    // CommonPageDataModel
    static let commonPageDataModelProgressDidUpdate = NSNotification.Name("commonPageDataModelDidUpdate")
    static let commonPageDataModelHeaderFieldTextDidUpdate = NSNotification.Name("commonPageDataModelHeaderFieldTextDidUpdate")
    static let commonPageDataModelDidBeginEditing = NSNotification.Name("commonPageDataModelDidBeginEditing")
    // FavoriteDataModel
    static let favoriteDataModelDidReload = NSNotification.Name("favoriteDataModelDidReload")
}
