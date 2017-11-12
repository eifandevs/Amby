//
//  PageHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

final class PageHistoryDataModel {
    static let s = PageHistoryDataModel()
    // 現在表示しているwebviewのインデックス
    var locationIndex: Int {
        didSet {
            log.debug("location index changed. \(oldValue) -> \(locationIndex)")
            UserDefaults.standard.set(locationIndex, forKey: AppConst.KEY_LOCATION_INDEX)
        }
    }
    // webViewそれぞれの履歴とカレントページインデックス
    var histories: [PageHistory] = []
    
    // 現在のページ情報
    var currentHistory: PageHistory? {
        return histories[safe: locationIndex]
    }
    
    // 現在のURL(jsのURL)
    var currentUrl: String {
        return histories[safe: locationIndex] != nil ? histories[locationIndex].url : ""
    }
    
    // 現在のコンテキスト
    var currentContext: String? {
        return PageHistoryDataModel.s.histories.count > locationIndex ? PageHistoryDataModel.s.histories[locationIndex].context : nil
    }
    
    private init() {
        // ロケーション情報取得
        locationIndex = UserDefaults.standard.integer(forKey: AppConst.KEY_LOCATION_INDEX)
        
        // pageHistory読み込み
        do {
            let data = try Data(contentsOf: AppConst.PATH_URL_PAGE_HISTORY)
            histories = NSKeyedUnarchiver.unarchiveObject(with: data) as! [PageHistory]
            log.debug("page history read.")
        } catch let error as NSError {
            histories.append(PageHistory())
            log.warning("failed to read page history: \(error)")
        }
    }
    /// 表示中ページの保存
    func store() {
        if histories.count > 0 {
            let pageHistoryData = NSKeyedArchiver.archivedData(withRootObject: histories)
            do {
                try pageHistoryData.write(to: AppConst.PATH_URL_PAGE_HISTORY)
                log.debug("store each history")
            } catch let error as NSError {
                log.error("failed to write: \(error)")
            }
        }
    }
    
    /// 表示中ページ情報の削除
    func delete() {
        Util.deleteFolder(path: AppConst.PATH_PAGE_HISTORY)
    }
}