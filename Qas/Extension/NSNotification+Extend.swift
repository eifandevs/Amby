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
    // PageHistoryDataModel
    static let pageHistoryDataModelDidReload = NSNotification.Name("pageHistoryDataModelDidReload")
    static let pageHistoryDataModelDidStartLoading = NSNotification.Name("pageHistoryDataModelDidStartLoading")
    static let pageHistoryDataModelDidEndLoading = NSNotification.Name("pageHistoryDataModelDidEndLoading")
    static let pageHistoryDataModelDidEndRendering = NSNotification.Name("pageHistoryDataModelDidEndRendering")
    
    // CommonHistoryDataModel
    static let commonHistoryDataModelDidGoForward = NSNotification.Name("commonHistoryDataModelDidGoForward")
}
