//
//  HistoryMenuViewModel.swift
//  Weasel
//
//  Created by User on 2017/06/14.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class HistoryMenuViewModel: OptionMenuTableViewModel {
    
    private var commonHistoryByDate: [[String: [CommonHistoryItem]]] = []
    private var readIndex = 0
    private let readInterval = 6
    private var readFiles: [String] = []
    
    override init() {
        super.init()
    }
    
    override func setup() {
        let manager = FileManager.default
        do {
            let list = try manager.contentsOfDirectory(atPath: AppDataManager.shared.commonHistoryPath)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            })
        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
        updateHistoryData()
        commonAction = { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
            let encodedText = menuItem.url!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            NotificationCenter.default.post(name: .baseViewModelWillSearchWebView, object: encodedText!)
            return nil
        }
    }
    
    func updateHistoryData() {
        if readFiles.count > 0 {
            let latestFiles = readFiles.prefix(readInterval)
            readFiles = Array(readFiles.dropFirst(readInterval))
            latestFiles.forEach({ (keyStr: String) in
                do {
                    let data = try Data(contentsOf: AppDataManager.shared.commonHistoryUrl(date: keyStr))
                    let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistoryItem]
                    commonHistoryByDate.append([keyStr: commonHistory])
                    sectionItems.append(keyStr)
                    menuItems.append(commonHistory.map({ (item) -> OptionMenuItem in
                        return OptionMenuItem(_id: item._id, type: .deletablePlain, title: item.title, url: item.url, date: item.date)
                    }))
                    log.debug("common history read. key: \(keyStr)")
                } catch let error as NSError {
                    log.error("failed to read common history. error: \(error.localizedDescription)")
                }
            })
        }
    }
}
