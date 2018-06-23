//
//  SearchHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

final class SearchHistoryDataModel {
    static let s = SearchHistoryDataModel()
    var histories = [SearchHistory]()

    /// userdefault repository
    private let userDefaultRepository = UserDefaultRepository()

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    /// 保存済みリスト取得
    func getList() -> [String] {
        if let list = localStorageRepository.getList(.searchHistory(resource: nil)) {
            return list.map({ (path: String) -> String in
                path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).sorted(by: { $1.toDate() < $0.toDate() })
        }

        return []
    }

    /// store with search word
    func store(text: String) {
        store(histories: [SearchHistory(title: text, date: Date())])
    }

    /// 検索履歴の保存
    func store(histories: [SearchHistory]) {

        if histories.count > 0 {
            // searchHistoryを日付毎に分ける
            var searchHistoryByDate: [String: [SearchHistory]] = [:]
            for item in histories {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: NSLocale.current.identifier)
                dateFormatter.dateFormat = AppConst.APP_DATE_FORMAT
                let key = dateFormatter.string(from: item.date)
                if searchHistoryByDate[key] == nil {
                    searchHistoryByDate[key] = [item]
                } else {
                    searchHistoryByDate[key]?.append(item)
                }
            }

            for (key, value) in searchHistoryByDate {
                let filename = "\(key).dat"

                let saveData: [SearchHistory] = { () -> [SearchHistory] in
                    if let data = localStorageRepository.getData(.searchHistory(resource: filename)) {
                        let old = NSKeyedUnarchiver.unarchiveObject(with: data) as! [SearchHistory]
                        let saveData: [SearchHistory] = value + old
                        return saveData
                    }

                    return value
                }()

                let searchHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                localStorageRepository.write(.searchHistory(resource: filename), data: searchHistoryData)
            }
        }
    }

    /// 検索履歴の検索
    /// 検索ワードと検索件数を指定する
    /// 指定ワードを含むかどうか
    func select(title: String, readNum: Int) -> [SearchHistory] {
        var result: [SearchHistory] = []
        let readFiles = getList().reversed()

        if readFiles.count > 0 {
            let latestFiles = readFiles.prefix(readNum)
            var allSearchHistory: [SearchHistory] = []
            latestFiles.forEach({ (keyStr: String) in
                let filename = "\(keyStr).dat"

                if let data = localStorageRepository.getData(.searchHistory(resource: filename)) {
                    let searchHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as! [SearchHistory]
                    allSearchHistory += searchHistory
                }
            })
            let hitSearchHistory = allSearchHistory.filter({ (searchHistoryItem) -> Bool in
                searchHistoryItem.title.lowercased().contains(title.lowercased())
            })

            // 重複の削除
            hitSearchHistory.forEach({ item in
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

        histories = result
        return result
    }

    /// 閲覧履歴の期限切れ削除
    func expireCheck() {
        let saveTerm = userDefaultRepository.searchHistorySaveCount
        let readFiles = getList().reversed()

        if readFiles.count > saveTerm {
            let deleteFiles = readFiles.prefix(readFiles.count - saveTerm)
            deleteFiles.forEach({ key in
                let filename = "\(key).dat"
                localStorageRepository.delete(.searchHistory(resource: filename))
            })
            log.debug("deleteSearchHistory: \(deleteFiles)")
        }
    }

    /// 検索履歴を全て削除
    func delete() {
        localStorageRepository.delete(.searchHistory(resource: nil))
        localStorageRepository.create(.searchHistory(resource: nil))
    }
}
