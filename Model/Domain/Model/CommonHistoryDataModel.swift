//
//  CommonHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

enum CommonHistoryDataModelAction {
    case deleteAll
}

enum CommonHistoryDataModelError {
    case getList
    case delete
    case store
    case select
    case expireCheck
}

extension CommonHistoryDataModelError: ModelError {
    var message: String {
        switch self {
        case .getList, .select, .expireCheck:
            return MessageConst.NOTIFICATION.GET_COMMON_HISTORY_ERROR
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_COMMON_HISTORY_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_COMMON_HISTORY_ERROR
        }
    }
}

protocol CommonHistoryDataModelProtocol {
    var rx_action: PublishSubject<CommonHistoryDataModelAction> { get }
    var rx_error: PublishSubject<CommonHistoryDataModelError> { get }
    var histories: [CommonHistory] { get }
    func insert(url: URL?, title: String?)
    func insert(url: URL?, title: String?, date: Date)
    func getHistory(index: Int) -> CommonHistory?
    func store()
    func getList() -> [String]
    func select(dateString: String) -> [CommonHistory]
    func select(title: String, readNum: Int) -> [CommonHistory]
    func expireCheck(historySaveCount: Int)
    func delete(historyIds: [String: [String]])
    func delete()
}

final class CommonHistoryDataModel: CommonHistoryDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<CommonHistoryDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<CommonHistoryDataModelError>()

    private let disposeBag = DisposeBag()

    static let s = CommonHistoryDataModel()

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    /// 閲覧履歴
    public private(set) var histories = [CommonHistory]()

    private init() {}

    /// insert with URL
    func insert(url: URL?, title: String?) {
        insert(url: url, title: title, date: Date())
    }

    /// insert with data
    func insert(url: URL?, title: String?, date: Date) {
        if let url = url?.absoluteString, let title = title, !url.isEmpty && !title.isEmpty {
            let currentUrl = histories.count > 0 ? histories.first!.url : nil

            // do not duplicate registration
            if url != currentUrl, url.isValidUrl {
                // Common History
                let history = CommonHistory(url: url, title: title, date: date)
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
                dateFormatter.dateFormat = ModelConst.APP.DATE_FORMAT
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
                    let result = localStorageRepository.getData(.commonHistory(resource: filename))
                    if case let .success(data) = result {
                        if let old = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CommonHistory] {
                            let saveData: [CommonHistory] = value + old
                            return saveData
                        }
                    }

                    return value
                }()
                let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                _ = localStorageRepository.write(.commonHistory(resource: filename), data: commonHistoryData)
            }
            histories = []
        }
    }

    /// 保存済みリスト取得
    /// 降順で返す。[20170909, 20170908, ...]
    func getList() -> [String] {
        let result = localStorageRepository.getList(.commonHistory(resource: nil))

        if case let .success(list) = result {
            return list.map({ (path: String) -> String in
                path.substring(to: path.index(path.startIndex, offsetBy: 8))
            }).sorted(by: { $1.toDate() < $0.toDate() })
        }

        return []
    }

    /// 閲覧履歴の検索
    /// 日付指定
    func select(dateString: String) -> [CommonHistory] {
        let filename = "\(dateString).dat"

        let result = localStorageRepository.getData(.commonHistory(resource: filename))

        if case let .success(data) = result {
            if let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CommonHistory] {
                return commonHistory
            }
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

                for keyStr in latestFiles {
                    let filename = "\(keyStr).dat"
                    let result = localStorageRepository.getData(.commonHistory(resource: filename))

                    if case let .success(data) = result {
                        if let commonHistory = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CommonHistory] {
                            allCommonHistory += commonHistory
                        }
                    }
                }
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
    func expireCheck(historySaveCount: Int) {
        let readFiles = getList().reversed()

        if readFiles.count > historySaveCount {
            let deleteFiles = readFiles.prefix(readFiles.count - historySaveCount)
            deleteFiles.forEach({ key in
                _ = localStorageRepository.delete(.commonHistory(resource: "\(key).dat"))
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
                let result = localStorageRepository.getData(.commonHistory(resource: filename))
                if case let .success(data) = result {
                    if let old = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CommonHistory] {
                        let saveData = old.filter({ (historyItem) -> Bool in
                            !value.contains(historyItem._id)
                        })

                        return saveData
                    }
                }

                return nil
            }()

            if let saveData = saveData {
                if saveData.count > 0 {
                    let commonHistoryData = NSKeyedArchiver.archivedData(withRootObject: saveData)
                    let result = localStorageRepository.write(.commonHistory(resource: filename), data: commonHistoryData)

                    if case .failure = result {
                        rx_error.onNext(.delete)
                    }

                } else {
                    let result = localStorageRepository.delete(.commonHistory(resource: filename))

                    if case .failure = result {
                        log.debug("remove common history file. date: \(key)")
                        rx_error.onNext(.delete)
                    }
                }
            }
        }
    }

    /// 閲覧履歴を全て削除
    func delete() {
        histories = []
        let deleteResult = localStorageRepository.delete(.commonHistory(resource: nil))

        if case .failure = deleteResult {
            rx_error.onNext(.delete)
            return
        }

        let createResult = localStorageRepository.create(.commonHistory(resource: nil))

        if case .success = createResult {
            rx_action.onNext(.deleteAll)
        } else {
            rx_error.onNext(.delete)
        }
    }
}
