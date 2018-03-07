//
//  CommonHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class CommonHistoryDataModel {
    
    let disposeBag = DisposeBag()
    
    static let s = CommonHistoryDataModel()
    
    /// ヒストリーバック通知用RX
    let rx_commonHistoryDataModelDidGoBack = PublishSubject<Void>()

    /// ヒストリーフォワード通知用RX
    let rx_commonHistoryDataModelDidGoForward = PublishSubject<Void>()
    
    /// 閲覧履歴
    var histories = [CommonHistory]()

    // 通知センター
    private let center = NotificationCenter.default
    
    /// 前の履歴に移動
    func goBack() {
        rx_commonHistoryDataModelDidGoBack.onNext(())
    }
    
    /// 閲覧履歴の永続化
    func store() {
        if histories.count > 0 {
            // commonHistoryを日付毎に分ける
            var commonHistoryByDate: [String: [CommonHistory]] = [:]
            for item in histories {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
                dateFormatter.dateFormat = AppConst.APP_DATE_FORMAT
                let key = dateFormatter.string(from: item.date)
                if commonHistoryByDate[key] == nil {
                    commonHistoryByDate[key] = [item]
                } else {
                    commonHistoryByDate[key]?.append(item)
                }
            }
            
            // 日付毎に分けた閲覧履歴を日付毎に保存していく
            for (key, value) in commonHistoryByDate {
                let commonHistoryUrl = Util.commonHistoryUrl(date: key)
                
                let saveData: [CommonHistory] = { () -> [CommonHistory] in
                    do {
                        let data = try Data(contentsOf: commonHistoryUrl)
                        let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
                        let saveData: [CommonHistory] = value + old
                        return saveData
                    } catch let error as NSError {
                        log.error("failed to read common history: \(error)")
                        return value
                    }
                }()
                
                let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                do {
                    try commonHistoryData.write(to: commonHistoryUrl)
                    log.debug("store common history")
                } catch let error as NSError {
                    log.error("failed to write common history: \(error)")
                }
            }
            histories = []
        }
    }

    /// 初期化
    func initialize() {
        histories = []
    }

    /// 保存済みリスト取得
    /// 降順で返す。[20170909, 20170908, ...]
    func getList() -> [String] {
        let manager = FileManager.default
        do {
            let list = try manager.contentsOfDirectory(atPath: AppConst.PATH_COMMON_HISTORY)
            return list.map({ (path: String) -> String in
                return path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).sorted(by: { $1.toDate() < $0.toDate() })
        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
        return []
    }
    
    /// 閲覧履歴の検索
    /// 日付指定
    func select(dateString: String) -> [CommonHistory] {
        do {
            let url = Util.commonHistoryUrl(date: dateString)
            let data = try Data(contentsOf: url)
            let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
            log.debug("common history read. url: \(url)")
            return commonHistory
        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
        return []
    }
    
    /// 検索ワードと検索件数を指定する
    func select(title: String, readNum: Int) -> [CommonHistory] {
        var result: [CommonHistory] = []
        do {
            let readFiles = getList().reversed()
            
            if readFiles.count > 0 {
                let latestFiles = readFiles.prefix(readNum)
                var allCommonHistory: [CommonHistory] = []
                latestFiles.forEach({ (keyStr: String) in
                    do {
                        let data = try Data(contentsOf: Util.commonHistoryUrl(date: keyStr))
                        let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
                        allCommonHistory += commonHistory
                    } catch let error as NSError {
                        log.error("failed to read common history. error: \(error.localizedDescription)")
                    }
                })
                let hitCommonHistory = allCommonHistory.filter({ (commonHistoryItem) -> Bool in
                    return commonHistoryItem.title.lowercased().contains(title)
                })
                
                // 重複の削除
                hitCommonHistory.forEach({ (item) in
                    if result.count == 0 {
                        result.append(item)
                    } else {
                        let resultTitles: [String] = result.map({ (item) -> String in
                            return item.title
                        })
                        if !resultTitles.contains(item.title) {
                            result.append(item)
                        }
                    }
                })
            }
            
        } catch let error as NSError {
            log.error("failed to read common history. error: \(error.localizedDescription)")
        }
        return result
    }
    
    /// 閲覧履歴の期限切れチェック
    func expireCheck() {
        let saveTerm = Int(UserDefaults.standard.integer(forKey: AppConst.KEY_COMMON_HISTORY_SAVE_COUNT))
        let readFiles = getList().reversed()
        
        if readFiles.count > saveTerm {
            let deleteFiles = readFiles.prefix(readFiles.count - saveTerm)
            deleteFiles.forEach({ (key) in
                do {
                    try FileManager.default.removeItem(atPath: Util.commonHistoryPath(date: key))
                } catch let error as NSError {
                    log.error("failed to delete common history. error: \(error.localizedDescription)")
                }
            })
            log.debug("deleteCommonHistory: \(deleteFiles)")
        }
    }
    
    /// 特定の閲覧履歴を削除する
    /// [日付: [id, id, ...]]
    func delete(historyIds: [String: [String]]) {
        // 履歴
        for (key, value) in historyIds {
            let commonHistoryUrl = Util.commonHistoryUrl(date: key)
            let saveData: [CommonHistory]? = { () -> [CommonHistory]? in
                do {
                    let data = try Data(contentsOf: commonHistoryUrl)
                    let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
                    let saveData = old.filter({ (historyItem) -> Bool in
                        return !value.contains(historyItem._id)
                    })
                    return saveData
                } catch let error as NSError {
                    log.error("failed to read: \(error)")
                    return nil
                }
            }()
            
            if let saveData = saveData {
                if saveData.count > 0 {
                    let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                    do {
                        try commonHistoryData.write(to: commonHistoryUrl)
                        log.debug("store common history")
                    } catch let error as NSError {
                        log.error("failed to write: \(error)")
                    }
                } else {
                    try! FileManager.default.removeItem(atPath: Util.commonHistoryPath(date: key))
                    log.debug("remove common history file. date: \(key)")
                }
            }
        }
    }
    
    /// 閲覧履歴を全て削除
    func delete() {
        histories = []
        Util.deleteFolder(path: AppConst.PATH_COMMON_HISTORY)
        Util.createFolder(path: AppConst.PATH_COMMON_HISTORY)
    }

}
