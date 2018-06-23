//
//  CommonHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CommonHistoryDataModel {
    let disposeBag = DisposeBag()

    static let s = CommonHistoryDataModel()

    /// ヒストリーバック通知用RX
    let rx_commonHistoryDataModelDidGoBack = PublishSubject<()>()

    /// ヒストリーフォワード通知用RX
    let rx_commonHistoryDataModelDidGoForward = PublishSubject<()>()

    /// userdefault storage repository
    private let userDefaultRepository = UserDefaultRepository()

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    /// 閲覧履歴
    public private(set) var histories = [CommonHistory]()

    // 通知センター
    private let center = NotificationCenter.default

    /// 前の履歴に移動
    func goBack() {
        rx_commonHistoryDataModelDidGoBack.onNext(())
    }

    /// 次の履歴に移動
    func goForward() {
        rx_commonHistoryDataModelDidGoForward.onNext(())
    }

    /// insert with URL
    func insert(url: URL?, title: String?) {
        if let url = url?.absoluteString, let title = title, !url.isEmpty && !title.isEmpty {
            if let currentUrl = PageHistoryDataModel.s.currentHistory?.url, currentUrl != url {
                // Common History
                let history = CommonHistory(url: url, title: title, date: Date())
                // 配列の先頭に追加する
                histories.insert(history, at: 0)

                log.debug("save common history. url: \(history.url) title: \(history.title)")
            }
        }
    }

    /// get the history with index
    func getHistory(index: Int) -> CommonHistory? {
        return histories[index]
    }

    /// 閲覧履歴の永続化
    func store() {
        if histories.count > 0 {
            // commonHistoryを日付毎に分ける
            var commonHistoryByDate: [String: [CommonHistory]] = [:]
            histories.forEach {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
                dateFormatter.dateFormat = AppConst.APP_DATE_FORMAT
                let key = dateFormatter.string(from: $0.date)
                if commonHistoryByDate[key] == nil {
                    commonHistoryByDate[key] = [$0]
                } else {
                    commonHistoryByDate[key]?.append($0)
                }
            }

            // 日付毎に分けた閲覧履歴を日付毎に保存していく
            for (key, value) in commonHistoryByDate {
                let filename = "\(key).dat"

                let saveData: [CommonHistory] = { () -> [CommonHistory] in
                    if let data = localStorageRepository.getData(.commonHistory(resource: filename)) {
                        let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
                        let saveData: [CommonHistory] = value + old
                        return saveData
                    } else {
                        return value
                    }
                }()

                let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                localStorageRepository.write(.commonHistory(resource: filename), data: commonHistoryData)
            }
            histories = []
        }
    }

    /// 保存済みリスト取得
    /// 降順で返す。[20170909, 20170908, ...]
    func getList() -> [String] {
        if let list = localStorageRepository.getList(.commonHistory(resource: nil)) {
            return list.map({ (path: String) -> String in
                path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).sorted(by: { $1.toDate() < $0.toDate() })
        }

        log.debug("not exist common history.")

        return []
    }

    /// 閲覧履歴の検索
    /// 日付指定
    func select(dateString: String) -> [CommonHistory] {
        let filename = "\(dateString).dat"

        if let data = localStorageRepository.getData(.commonHistory(resource: filename)) {
            let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
            return commonHistory
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
                    let filename = "\(keyStr).dat"
                    if let data = localStorageRepository.getData(.commonHistory(resource: filename)) {
                        let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
                        allCommonHistory += commonHistory
                    }
                })
                let hitCommonHistory = allCommonHistory.filter({ (commonHistoryItem) -> Bool in
                    commonHistoryItem.title.lowercased().contains(title.lowercased())
                })

                // 重複の削除
                hitCommonHistory.forEach({ item in
                    if result.count == 0 {
                        result.append(item)
                    } else {
                        let resultTitles: [String] = result.map({ (item) -> String in
                            item.title
                        })
                        if !resultTitles.contains(item.title) {
                            result.append(item)
                        }
                    }
                })
            }
        }
        return result
    }

    /// 閲覧履歴の件数チェック
    // デフォルトで90日分の履歴を超えたら削除する
    func expireCheck() {
        let historySaveCount = userDefaultRepository.commonHistorySaveCount
        let readFiles = getList().reversed()

        if readFiles.count > historySaveCount {
            let deleteFiles = readFiles.prefix(readFiles.count - historySaveCount)
            deleteFiles.forEach({ key in
                localStorageRepository.delete(.commonHistory(resource: "\(key).dat"))
            })
            log.debug("deleteCommonHistory: \(deleteFiles)")
        }
    }

    /// 特定の閲覧履歴を削除する
    /// [日付: [id, id, ...]]
    func delete(historyIds: [String: [String]]) {
        // 履歴
        for (key, value) in historyIds {
            let filename = "\(key).dat"

            let saveData: [CommonHistory]? = { () -> [CommonHistory]? in
                if let data = localStorageRepository.getData(.commonHistory(resource: filename)) {
                    let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CommonHistory]
                    let saveData = old.filter({ (historyItem) -> Bool in
                        !value.contains(historyItem._id)
                    })
                    return saveData
                }
                return nil
            }()

            if let saveData = saveData {
                if saveData.count > 0 {
                    let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                    localStorageRepository.write(.commonHistory(resource: filename), data: commonHistoryData)
                } else {
                    localStorageRepository.delete(.commonHistory(resource: filename))
                    log.debug("remove common history file. date: \(key)")
                }
            }
        }
    }

    /// 閲覧履歴を全て削除
    func delete() {
        histories = []
        localStorageRepository.delete(.commonHistory(resource: nil))
        localStorageRepository.create(.commonHistory(resource: nil))
    }
}
