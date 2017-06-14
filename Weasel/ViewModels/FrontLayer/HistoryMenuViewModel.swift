//
//  HistoryMenuViewModel.swift
//  Weasel
//
//  Created by User on 2017/06/14.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class HistoryMenuViewModel: OptionMenuTableViewModel {
    var commonHistoryByDate: [[String: [CommonHistoryItem]]] = []
    
    override init() {
        super.init()
        menuItems = [
            "bbbbb",
            "aaaaa"
        ]
        actionItems = [
            { () -> OptionMenuTableViewModel? in
                log.warning("tapped!!!!!")
                return nil
            },
            { () -> OptionMenuTableViewModel? in
                log.warning("tapped!!!!!")
                return nil
            }
        ]
    }
    
    override func setup() {
        // 履歴データ取得
        // eachHistory読み込み
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
        dateFormatter.dateFormat = "yyyyMMdd"
        let todayStr: String = dateFormatter.string(from: Date())
        
        for index in 0...6 {
            // デフォルトでは、過去7日分読み込む
            let keyStr = String(Int(todayStr)! - index)
            do {
                let data = try Data(contentsOf: AppDataManager.shared.commonHistoryPath(date: keyStr))
                let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistoryItem]
                commonHistoryByDate.append([keyStr: commonHistory])
                log.debug("common history read. key: \(keyStr)")
            } catch let error as NSError {
                log.error("failed to read each history. key: \(keyStr)")
            }
        }
    }
}
