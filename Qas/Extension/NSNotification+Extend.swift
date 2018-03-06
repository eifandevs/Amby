//
//  NSNotification+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/03/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

/// モデルデータ変更通知用の拡張
extension NSNotification.Name {
    // OperationDataModel
    static let operationDataModelDidChange = NSNotification.Name("operationDataModelDidChange")
    
    // PageHistoryDataModel
    static let pageHistoryDataModelDidReload = NSNotification.Name("pageHistoryDataModelDidReload")
    static let pageHistoryDataModelDidRemove = NSNotification.Name("pageHistoryDataModelDidRemove")
    static let pageHistoryDataModelDidInsert = NSNotification.Name("pageHistoryDataModelDidInsert")
    static let pageHistoryDataModelDidAppend = NSNotification.Name("pageHistoryDataModelDidAppend")
    static let pageHistoryDataModelDidChange = NSNotification.Name("pageHistoryDataModelDidChange")
    static let pageHistoryDataModelDidStartLoading = NSNotification.Name("pageHistoryDataModelDidStartLoading")
    static let pageHistoryDataModelDidEndLoading = NSNotification.Name("pageHistoryDataModelDidEndLoading")
    static let pageHistoryDataModelDidEndRendering = NSNotification.Name("pageHistoryDataModelDidEndRendering")
    
    // CommonHistoryDataModel
    static let commonHistoryDataModelDidGoForward = NSNotification.Name("commonHistoryDataModelDidGoForward")

    // HeaderViewDataModel
    static let headerViewDataModelProgressDidUpdate = NSNotification.Name("headerViewDataModelDidUpdate")
    static let headerViewDataModelHeaderFieldTextDidUpdate = NSNotification.Name("headerViewDataModelHeaderFieldTextDidUpdate")
    static let headerViewDataModelDidBeginEditing = NSNotification.Name("headerViewDataModelDidBeginEditing")
    
    // FavoriteDataModel
    static let favoriteDataModelDidReload = NSNotification.Name("favoriteDataModelDidReload")
    static let favoriteDataModelDidRemove = NSNotification.Name("favoriteDataModelDidRemove")
    static let favoriteDataModelDidInsert = NSNotification.Name("favoriteDataModelDidInsert")
}
