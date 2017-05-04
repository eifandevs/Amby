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
    let headerFieldWidth = DeviceDataManager.shared.displaySize.width / 1.6
    let thumbnailSize = CGSize(width: 105, height: 105 * UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height)
    let searchPath = "https://www.google.co.jp/search?q="
    let defaultUrlKey = "defaultUrl"
    let locationIndexKey = "locationIndex"
    let webViewTotalCountKey = "webViewTotalCount"
    let historySavableTermKey = "historySaveblaTerm"
    let appFont = "Avenir"
    let eachHistoryPath = URL(fileURLWithPath: DeviceDataManager.shared.cachesPath + "/each_history.dat")
    
    private init() {
        
    }
    
    func thumbnailPath(folder: String) -> URL {
        let path = DeviceDataManager.shared.cachesPath + "/thumbnails/\(folder)"
        createFolder(path: path)
        return URL(fileURLWithPath: path + "/thumbnail.png")
    }
    
    func thumbnailFolderPath(folder: String) -> URL {
        let path = DeviceDataManager.shared.cachesPath + "/thumbnails/\(folder)"
        return URL(fileURLWithPath: path)
    }
    
    func commonHistoryPath(date: String) -> URL {
        let path = DeviceDataManager.shared.cachesPath + "/common_history"
        createFolder(path: path)
        return URL(fileURLWithPath: path + "/\(date).dat")
    }
    
    private func createFolder(path: String) {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        
        if !isDir.boolValue {
            try! fileManager.createDirectory(atPath: path ,withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func registerDefaultData() {
        UserDefaults.standard.register(defaults: [defaultUrlKey: "https://www.amazon.co.jp/",
                                                  locationIndexKey: 0,
                                                  historySavableTermKey: 10])
    }
}
