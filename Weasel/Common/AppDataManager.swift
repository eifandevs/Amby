//
//  AppDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/07.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class AppDataManager {
    static let shared: AppDataManager = AppDataManager()
    let progressMin = 0.1
    let headerViewHeight = 45 + DeviceDataManager.shared.statusBarHeight
    let headerFieldWidth = DeviceDataManager.shared.displaySize.width / 1.8
    let edgeSwipeErea: CGFloat = 15.0
    let optionMenuCellHeight: CGFloat = 50
    let optionMenuSize: CGSize = CGSize(width: 250, height: 450)
    let thumbnailSize = CGSize(width: 105, height: 105 * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)
    let searchPath = "https://www.google.co.jp/search?q="
    let defaultUrlKey = "defaultUrl"
    let locationIndexKey = "locationIndex"
    let autoScrollIntervalKey = "autoScrollInterval"
    let appFont = "Avenir"
    let eachHistoryPath = URL(fileURLWithPath: DeviceDataManager.shared.cachesPath + "/each_history.dat")
    let commonHistoryPath = DeviceDataManager.shared.cachesPath + "/common_history"
    
    private init() {
        
    }
    
    func thumbnailUrl(folder: String) -> URL {
        let path = DeviceDataManager.shared.cachesPath + "/thumbnails/\(folder)"
        Util.shared.createFolder(path: path)
        return URL(fileURLWithPath: path + "/thumbnail.png")
    }
    
    func thumbnailFolderUrl(folder: String) -> URL {
        let path = DeviceDataManager.shared.cachesPath + "/thumbnails/\(folder)"
        return URL(fileURLWithPath: path)
    }
    
    func commonHistoryUrl(date: String) -> URL {
        let path = DeviceDataManager.shared.cachesPath + "/common_history"
        Util.shared.createFolder(path: path)
        return URL(fileURLWithPath: path + "/\(date).dat")
    }
    
    func commonHistoryFilePath(date: String) -> String {
        let path = DeviceDataManager.shared.cachesPath + "/common_history"
        return path + "/\(date).dat"
    }
    
    func registerDefaultData() {
        UserDefaults.standard.register(defaults: [defaultUrlKey: "https://www.amazon.co.jp/",
                                                  locationIndexKey: 0,
                                                  autoScrollIntervalKey: 0.06])
    }
}
