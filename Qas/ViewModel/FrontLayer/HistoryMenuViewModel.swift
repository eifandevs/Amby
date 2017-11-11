//
//  HistoryMenuViewModel.swift
//  Qas
//
//  Created by User on 2017/06/14.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class HistoryMenuViewModel: OptionMenuTableViewModel {
    
    private var commonHistoryByDate: [[String: [CommonHistory]]] = []
    private var readIndex = 0
    private let readInterval = 6
    private var readFiles: [String] = []
    
    override init() {
        super.init()
    }
    
    override func setup() {
        let manager = FileManager.default
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.PATH_COMMON_HISTORY)
            readFiles = list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).reversed()
        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
        updateHistoryData()
        commonAction = { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
            NotificationCenter.default.post(name: .baseViewModelWillSearchWebView, object: menuItem.url!)
            return nil
        }
    }
    
    func updateHistoryData() {
        if readFiles.count > 0 {
            let latestFiles = readFiles.prefix(readInterval)
            readFiles = Array(readFiles.dropFirst(readInterval))
            latestFiles.forEach({ (keyStr: String) in
                do {
                    let data = try Data(contentsOf: Util.commonHistoryUrl(date: keyStr))
                    let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
                    commonHistoryByDate.append([keyStr: commonHistory])
                    sectionItems.append(keyStr)
                    menuItems.append(commonHistory.map({ (item) -> OptionMenuItem in
                        let decodedUrl = item.url.removingPercentEncoding!
                        return OptionMenuItem(_id: item._id, type: .deletablePlain, title: item.title, url: decodedUrl, date: item.date)
                    }))
                    log.debug("common history read. key: \(keyStr)")
                } catch let error as NSError {
                    log.error("failed to read common history. error: \(error.localizedDescription)")
                }
            })
        }
    }
}
