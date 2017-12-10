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
    static let baseViewModelWillInitialize = NSNotification.Name("baseViewModelWillInitialize")
    static let baseViewModelWillCopyUrl = NSNotification.Name("baseViewModelWillCopyUrl")
    static let baseViewModelWillSearchWebView = NSNotification.Name("baseViewModelWillSearchWebView")
    static let baseViewModelWillRegisterAsForm = NSNotification.Name("baseViewModelWillRegisterAsForm")
    static let baseViewModelWillAutoScroll = NSNotification.Name("baseViewModelWillAutoScroll")
    static let searchMenuTableViewModelWillUpdateSearchToken = NSNotification.Name("searchMenuTableViewModelWillUpdateSearchToken")
    
    // MARK: - Model
    // OperationDataModel
    static let operationDataModelDidChange = NSNotification.Name("operationDataModelDidChange")
    
    // PageHistoryDataModel
    static let pageHistoryDataModelDidReload = NSNotification.Name("pageHistoryDataModelDidReload")
    static let pageHistoryDataModelDidRemove = NSNotification.Name("pageHistoryDataModelDidRemove")
    static let pageHistoryDataModelDidInsert = NSNotification.Name("pageHistoryDataModelDidInsert")
    static let pageHistoryDataModelDidChange = NSNotification.Name("pageHistoryDataModelDidChange")
    static let pageHistoryDataModelDidStartLoading = NSNotification.Name("pageHistoryDataModelDidStartLoading")
    static let pageHistoryDataModelDidEndLoading = NSNotification.Name("pageHistoryDataModelDidEndLoading")
    
    // CommonHistoryDataModel
    static let commonHistoryDataModelDidGoBack = NSNotification.Name("commonHistoryDataModelDidGoBack")
    static let commonHistoryDataModelDidGoForward = NSNotification.Name("commonHistoryDataModelDidGoForward")
    static let commonHistoryDataModelDidDelete = NSNotification.Name("commonHistoryDataModelDidDelete")

    // HeaderViewDataModel
    static let headerViewDataModelProgressDidUpdate = NSNotification.Name("headerViewDataModelDidUpdate")
    static let headerViewDataModelHeaderFieldTextDidUpdate = NSNotification.Name("headerViewDataModelHeaderFieldTextDidUpdate")
    static let headerViewDataModelDidBeginEditing = NSNotification.Name("headerViewDataModelDidBeginEditing")
    
    // FavoriteDataModel
    static let favoriteDataModelDidReload = NSNotification.Name("favoriteDataModelDidReload")
}
