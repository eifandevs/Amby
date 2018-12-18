//
//  PageHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum PageHistoryDataModelAction {
    case insert(pageHistory: PageHistory, at: Int)
    case append(pageHistory: PageHistory)
    case change(context: String)
    case delete(deleteContext: String, currentContext: String?, deleteIndex: Int)
    case reload
    case load(url: String)
    case startLoading(context: String)
    case endLoading(context: String)
    case endRendering(context: String)
}

enum PageHistoryDataModelError {
    case delete
    case store
}

extension PageHistoryDataModelError: ModelError {
    var message: String {
        switch self {
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_PAGE_HISTORY_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_PAGE_HISTORY_ERROR
        }
    }
}

final class PageHistoryDataModel {
    /// ページインサート通知用RX
    let rx_pageHistoryDataModelDidInsert = PublishSubject<(pageHistory: PageHistory, at: Int)>()
    /// ページ追加通知用RX
    let rx_pageHistoryDataModelDidAppend = PublishSubject<PageHistory>()
    /// ページ変更通知用RX
    let rx_pageHistoryDataModelDidChange = PublishSubject<String>()
    /// ページ削除通知用RX
    let rx_pageHistoryDataModelDidRemove = PublishSubject<(deleteContext: String, currentContext: String?, deleteIndex: Int)>()
    /// ページリロード通知用RX
    let rx_pageHistoryDataModelDidReload = PublishSubject<()>()
    /// ページロード開始通知用RX
    let rx_pageHistoryDataModelDidStartLoading = PublishSubject<String>()
    /// ページロード終了通知用RX
    let rx_pageHistoryDataModelDidEndLoading = PublishSubject<String>()
    /// ページレンダリング終了通知用RX
    let rx_pageHistoryDataModelDidEndRendering = PublishSubject<String>()
    /// アクション通知用RX
    let rx_action = PublishSubject<PageHistoryDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<PageHistoryDataModelError>()

    static let s = PageHistoryDataModel()

    /// 通知センター
    private let center = NotificationCenter.default

    /// 現在表示しているwebviewのコンテキスト
    var currentContext: String {
        get {
            return SettingDataModel.s.currentContext
        }
        set(value) {
            let context = currentContext
            log.debug("current context changed. \(currentContext) -> \(value)")
            previousContext = context
            SettingDataModel.s.currentContext = value
        }
    }

    var previousContext: String?

    /// webViewそれぞれの履歴とカレントページインデックス
    public private(set) var histories = [PageHistory]()

    /// 現在のページ情報
    var currentHistory: PageHistory? {
        return histories.find({ $0.context == currentContext })
    }

    /// 現在の位置
    var currentLocation: Int? {
        return histories.index(where: { $0.context == currentContext })
    }

    /// 最新ページを見ているかフラグ
    private var isViewingLatest: Bool {
        return currentLocation == histories.count - 1
    }

    /// ページヒストリー保存件数
    private let pageHistorySaveCount = SettingDataModel.s.pageHistorySaveCount

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    private init() {}

    /// 初期化
    func initialize() {
        // pageHistory読み込み
        let result = localStorageRepository.getData(.pageHistory)
        if case let .success(data) = result {
            if let histories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PageHistory] {
                self.histories = histories
            } else {
                histories = []
                log.error("unarchive histories error.")
            }
        } else {
            let pageHistory = PageHistory()
            histories.append(pageHistory)
            currentContext = pageHistory.context
        }
    }

    /// get the history with context
    func getHistory(context: String) -> PageHistory? {
        return histories.find({ $0.context == context })
    }

    /// get the history with index
    func getHistory(index: Int) -> PageHistory? {
        return histories[index]
    }

    /// get isLoading property
    func getIsLoading(context: String) -> Bool? {
        if let history = histories.find({ $0.context == context }) {
            return history.isLoading
        }
        return nil
    }

    /// ロード開始
    func startLoading(context: String) {
        if let history = histories.find({ $0.context == context }) {
            history.isLoading = true
            rx_pageHistoryDataModelDidStartLoading.onNext(context)
        }
    }

    /// ロード終了
    func endLoading(context: String) {
        if let history = histories.find({ $0.context == context }) {
            history.isLoading = false
            rx_pageHistoryDataModelDidEndLoading.onNext(context)
        } else {
            log.error("pageHistoryDataModelDidEndLoading not fired. history is deleted.")
        }
    }

    /// 描画終了
    func endRendering(context: String) {
        if histories.find({ $0.context == context }) != nil {
            rx_pageHistoryDataModelDidEndRendering.onNext(context)
        } else {
            log.error("pageHistoryDataModelDidEndRendering not fired. history is deleted.")
        }
    }

    /// 過去のページを閲覧しているかのフラグ
    func isPastViewing(context: String) -> Bool? {
        if let history = histories.find({ $0.context == context }) {
            return history.backForwardList.count != 0 && history.listIndex != history.backForwardList.count - 1
        }
        return nil
    }

    /// 直近URL取得
    func getMostForwardUrl(context: String) -> String? {
        if let history = histories.find({ $0.context == context }), let url = history.backForwardList.last, !url.isEmpty {
            return url
        }
        return nil
    }

    /// 前回URL取得
    func getBackUrl(context: String) -> String? {
        if let history = histories.find({ $0.context == context }), history.listIndex > 0 {
            // インデックス調整
            history.listIndex -= 1

            return history.backForwardList[history.listIndex]
        }
        return nil
    }

    /// 次URL取得
    func getForwardUrl(context: String) -> String? {
        if let history = histories.find({ $0.context == context }), history.listIndex < history.backForwardList.count - 1 {
            // インデックス調整
            history.listIndex += 1

            return history.backForwardList[history.listIndex]
        }
        return nil
    }

    /// update url with context
    func updateUrl(context: String, url: String, operation: PageHistory.Operation) {
        var isChanged = false

        /// 通常の遷移の場合（ヒストリバックやフォワードではない）
        if !url.isEmpty && url.isValidUrl {
            histories.forEach({
                if $0.context == context {
                    isChanged = true
                    $0.url = url

                    log.debug("save page history url. url: \(url)")

                    if let isPastViewing = isPastViewing(context: context) {
                        if operation == .normal {
                            // 更新判定
                            if let lastUrl = $0.backForwardList.last, lastUrl == url {
                                return
                            }

                            // リスト更新
                            if !isPastViewing {
                                log.debug("add backForwardList.")
                                $0.backForwardList.append(url)
                            } else {
                                log.debug("refactor backForwardList.")
                                // ヒストリーバック -> 通常遷移の場合は、履歴リストを再構築する
                                $0.backForwardList = Array($0.backForwardList.prefix($0.listIndex + 1))
                                $0.backForwardList.append(url)
                            }

                            // 保存件数を超えた場合は、削除する
                            if $0.backForwardList.count > pageHistorySaveCount {
                                log.warning("over backForwardList max.")
                                $0.backForwardList = Array($0.backForwardList.suffix(pageHistorySaveCount))
                            }

                            // インデックス調整
                            $0.listIndex = $0.backForwardList.count - 1

                            log.debug("change backForwardList. listIndex: \($0.listIndex) backForwardList: \($0.backForwardList)")
                        } else {
                            log.debug("not change backForwardList.")
                        }
                    } else {
                        log.error("isPastViewing error.")
                    }
                    return
                }
            })
        }

        // if change front context, reload header view
        if isChanged && context == currentContext {
            ProgressDataModel.s.updateText(text: url)
            FavoriteDataModel.s.reload()
        }
    }

    /// update title with context
    func updateTitle(context: String, title: String) {
        if !title.isEmpty && title != "読み込みエラー" {
            histories.forEach({
                if $0.context == context {
                    $0.title = title
                    log.debug("save page history title. title: \(title)")

                    return
                }
            })
        }
    }

    /// ページ挿入(new window event)
    func insert(url: String?, title: String? = nil) {
        if isViewingLatest {
            // 最新ページを見ているなら、insertではないので、appendに切り替える
            append(url: url, title: title ?? "")
        } else {
            if let currentLocation = currentLocation {
                let newPage = PageHistory(url: url ?? "", title: title ?? "")
                histories.insert(newPage, at: currentLocation + 1)
                currentContext = newPage.context
                rx_pageHistoryDataModelDidInsert.onNext((pageHistory: newPage, at: currentLocation + 1))
            }
        }
    }

    /// add page
    func append(url: String?, title: String? = nil) {
        let newPage = PageHistory(url: url ?? "", title: title ?? "")
        histories.append(newPage)
        currentContext = newPage.context
        rx_pageHistoryDataModelDidAppend.onNext(newPage)
    }

    /// ページコピー
    func copy() {
        if let currentHistory = currentHistory {
            if isViewingLatest {
                // 最新ページを見ているなら、insertではないので、appendに切り替える
                let newPage = PageHistory(url: currentHistory.url, title: currentHistory.title)
                histories.append(newPage)
                currentContext = newPage.context
                rx_pageHistoryDataModelDidAppend.onNext(newPage)
            } else {
                if let currentLocation = currentLocation {
                    let newPage = PageHistory(url: currentHistory.url, title: currentHistory.title)
                    histories.insert(newPage, at: currentLocation + 1)
                    currentContext = newPage.context
                    rx_pageHistoryDataModelDidInsert.onNext((pageHistory: newPage, at: currentLocation + 1))
                }
            }
        }
    }

    /// ページリロード
    func reload() {
        rx_pageHistoryDataModelDidReload.onNext(())
    }

    /// ぺージインデックス取得
    func getIndex(context: String) -> Int? {
        return histories.index(where: { $0.context == context })
    }

    /// 指定ページの削除
    func remove(context: String) {
        // 削除インデックス取得
        if let deleteIndex = histories.index(where: { $0.context == context }) {
            // フロントの削除かどうか
            if context == currentContext {
                histories.remove(at: deleteIndex)
                // 削除した結果、ページが存在しない場合は作成する
                if histories.count == 0 {
                    rx_pageHistoryDataModelDidRemove.onNext((deleteContext: context, currentContext: nil, deleteIndex: deleteIndex))
                    let pageHistory = PageHistory()
                    histories.append(pageHistory)
                    currentContext = pageHistory.context
                    rx_pageHistoryDataModelDidAppend.onNext(pageHistory)

                    return
                } else {
                    // 最後の要素を削除した場合は、前のページに戻る
                    if deleteIndex == histories.count {
                        currentContext = histories[deleteIndex - 1].context
                    } else {
                        currentContext = histories[deleteIndex].context
                    }
                }
            } else {
                histories.remove(at: deleteIndex)
            }
            rx_pageHistoryDataModelDidRemove.onNext((deleteContext: context, currentContext: currentContext, deleteIndex: deleteIndex))
        } else {
            log.error("cannot find delete context.")
        }
    }

    /// 表示中ページの変更
    func change(context: String) {
        currentContext = context
        rx_pageHistoryDataModelDidChange.onNext(currentContext)
    }

    /// 前ページに変更
    func goBack() {
        if let currentLocation = currentLocation, histories.count > 0 {
            let targetContext = histories[0 ... histories.count - 1 ~= currentLocation - 1 ? currentLocation - 1 : histories.count - 1].context
            currentContext = targetContext
            rx_pageHistoryDataModelDidChange.onNext(currentContext)
        }
    }

    /// 次ページに変更
    func goNext() {
        if let currentLocation = currentLocation, histories.count > 0 {
            let targetContext = histories[0 ... histories.count - 1 ~= currentLocation + 1 ? currentLocation + 1 : 0].context
            currentContext = targetContext
            rx_pageHistoryDataModelDidChange.onNext(currentContext)
        }
    }

    /// 表示中ページの保存
    func store() {
        if histories.count > 0 {
            let pageHistoryData = NSKeyedArchiver.archivedData(withRootObject: histories)
            let result = localStorageRepository.write(.pageHistory, data: pageHistoryData)

            if case .failure = result {
                rx_error.onNext(.store)
            }
        }
    }

    /// 全データの削除
    func delete() {
        histories = []
        let result = localStorageRepository.delete(.pageHistory)

        if case .failure = result {
            rx_error.onNext(.delete)
        }
    }
}
