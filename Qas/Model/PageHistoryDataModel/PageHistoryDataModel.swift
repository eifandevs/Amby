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
            UserDefaults.standard.set(locationIndex, forKey: AppConst.locationIndexKey)
        }
    }
    // webViewそれぞれの履歴とカレントページインデックス
    var histories: [PageHistory] = []
    
    private init() {
        // ロケーション情報取得
        locationIndex = UserDefaults.standard.integer(forKey: AppConst.locationIndexKey)
        
        // pageHistory読み込み
        do {
            let data = try Data(contentsOf: AppConst.pageHistoryUrl)
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
                try pageHistoryData.write(to: AppConst.pageHistoryUrl)
                log.debug("store each history")
            } catch let error as NSError {
                log.error("failed to write: \(error)")
            }
        }
    }
}

class PageHistory: NSObject, NSCoding {
    var context: String = NSUUID().uuidString
    var isPrivate: String = "false"
    var url: String = ""
    var title: String = ""
    
    override init() {
        super.init()
    }
    
    init(context: String = NSUUID().uuidString, url: String = "", title: String = "", isPrivate: String = "false") {
        self.context = context
        self.url = url
        self.title = title
        self.isPrivate = isPrivate
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let context = decoder.decodeObject(forKey: "context") as! String
        let url = decoder.decodeObject(forKey: "url") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let isPrivate = decoder.decodeObject(forKey: "isPrivate") as! String
        self.init(context: context, url: url, title: title, isPrivate: isPrivate)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(context, forKey: "context")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(isPrivate, forKey: "isPrivate")
    }
}
