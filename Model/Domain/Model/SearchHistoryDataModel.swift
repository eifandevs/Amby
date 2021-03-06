//
//  SearchHistoryModel.swift
//  Amby
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import CommonUtil
import Entity
import Foundation
import RxCocoa
import RxSwift

enum SearchHistoryDataModelAction {
    case delete
    case deleteAll
}

enum SearchHistoryDataModelError {
    case getList
    case delete
    case store
    case select
    case expireCheck
}

extension SearchHistoryDataModelError: ModelError {
    var message: String {
        switch self {
        case .getList, .select, .expireCheck:
            return MessageConst.NOTIFICATION.GET_SEARCH_HISTORY_ERROR
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_SEARCH_HISTORY_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_SEARCH_HISTORY_ERROR
        }
    }
}

protocol SearchHistoryDataModelProtocol {
    var rx_action: PublishSubject<SearchHistoryDataModelAction> { get }
    var rx_error: PublishSubject<SearchHistoryDataModelError> { get }
    var histories: [SearchHistory] { get }
    func getList() -> [String]
    func store(text: String)
    func store(histories: [SearchHistory])
    func select(title: String, readNum: Int) -> [SearchHistory]
    func expireCheck()
    func delete()
}

final class SearchHistoryDataModel: SearchHistoryDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<SearchHistoryDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<SearchHistoryDataModelError>()

    static let s = SearchHistoryDataModel()
    var histories = [SearchHistory]()

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    private let userDefaultRepository = UserDefaultRepository()

    private init() {}

    /// 保存済みリスト取得
    func getList() -> [String] {
        let result = localStorageRepository.getList(.searchHistory(resource: nil))

        if case let .success(value) = result {
            return value.map({ (path: String) -> String in
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
                dateFormatter.dateFormat = ModelConst.APP.DATE_FORMAT
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
                    let result = localStorageRepository.getData(.searchHistory(resource: filename))

                    if case let .success(data) = result {
                        if let old = NSKeyedUnarchiver.unarchiveObject(with: data) as? [SearchHistory] {
                            return value + old
                        }
                    }

                    return value
                }()

                let searchHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                _ = localStorageRepository.write(.searchHistory(resource: filename), data: searchHistoryData)
            }
        }
    }

    /// 検索履歴の検索
    /// 検索ワードと検索件数を指定する
    /// 指定ワードを含むかどうか
    func select(title: String, readNum: Int) -> [SearchHistory] {
        let readFiles = getList().reversed()

        if readFiles.count > 0 {
            let latestFiles = readFiles.prefix(readNum)
            var allSearchHistory: [SearchHistory] = []

            for keyStr in latestFiles {
                let filename = "\(keyStr).dat"

                let result = localStorageRepository.getData(.searchHistory(resource: filename))

                if case let .success(data) = result {
                    if let searchHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as? [SearchHistory] {
                        allSearchHistory += searchHistory
                    }
                }
            }

            let hitSearchHistory = allSearchHistory.filter({ (searchHistoryItem) -> Bool in
                searchHistoryItem.title.lowercased().contains(title.lowercased())
            }).reduce([]) { (result, value) -> [SearchHistory] in
                return result.map { $0.title }.contains(value.title) ? result : result + [value]
            }

            histories = hitSearchHistory
            return hitSearchHistory

        }

        return []
    }

    /// 閲覧履歴の期限切れ削除
    func expireCheck() {
        let saveTerm = userDefaultRepository.get(key: .searchHistorySaveCount)
        let readFiles = getList().reversed()

        if readFiles.count > saveTerm {
            let deleteFiles = readFiles.prefix(readFiles.count - saveTerm)
            for key in deleteFiles {
                let filename = "\(key).dat"

                _ = localStorageRepository.delete(.searchHistory(resource: filename))
            }
            log.debug("deleteSearchHistory: \(deleteFiles)")
        }

        rx_action.onNext(.delete)
    }

    /// 検索履歴を全て削除
    func delete() {
        let deleteResult = localStorageRepository.delete(.searchHistory(resource: nil))

        if case .failure = deleteResult {
            rx_error.onNext(.delete)
            return
        }

        let createResult = localStorageRepository.create(.searchHistory(resource: nil))

        if case .success = createResult {
            rx_action.onNext(.deleteAll)
        } else {
            rx_error.onNext(.delete)
        }
    }
}
