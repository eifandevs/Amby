//
//  PageHistoryModel.swift
//  Qas
//
//  Created by temma on 2017/10/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import CommonUtil
import Entity
import Foundation
import RxCocoa
import RxSwift

enum PageHistoryDataModelAction {
    case insert(before: (pageHistory: PageHistory, index: Int), after: (pageHistory: PageHistory, index: Int))
    case append(before: (pageHistory: PageHistory, index: Int)?, after: (pageHistory: PageHistory, index: Int))
    case appendGroup
    case changeGroupTitle(groupContext: String, title: String)
    case deleteGroup(groupContext: String)
    case invertPrivateMode
    case change(before: (pageHistory: PageHistory, index: Int), after: (pageHistory: PageHistory, index: Int))
    case delete(isFront: Bool, deleteContext: String, currentContext: String?, deleteIndex: Int)
    case swap(start: Int, end: Int)
    case reload
    case rebuild
    case rebuildThumbnail
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

protocol PageHistoryDataModelProtocol {
    var rx_action: PublishSubject<PageHistoryDataModelAction> { get }
    var rx_error: PublishSubject<PageHistoryDataModelError> { get }
    var pageGroupList: PageGroupList { get }
    var currentContext: String { get set }
    var histories: [PageHistory] { get }
    var currentHistory: PageHistory? { get }
    var currentLocation: Int? { get }
    func getHistory(context: String) -> PageHistory?
    func getHistory(index: Int) -> PageHistory?
    func getIsLoading(context: String) -> Bool?
    func startLoading(context: String)
    func endLoading(context: String)
    func endRendering(context: String)
    func isPastViewing(context: String) -> Bool?
    func getMostForwardUrl(context: String) -> String?
    func getBackUrl(context: String) -> String?
    func getForwardUrl(context: String) -> String?
    func swap(start: Int, end: Int)
    func updateUrl(context: String, url: String, operation: PageHistory.Operation) -> Bool
    func updateTitle(context: String, title: String)
    func insert(url: String?, title: String?)
    func append(url: String?, title: String?)
    func appendGroup()
    func changeGroupTitle(groupContext: String, title: String)
    func removeGroup(groupContext: String)
    func invertPrivateMode(groupContext: String)
    func copy()
    func reload()
    func rebuild()
    func getIndex(context: String) -> Int?
    func remove(context: String)
    func change(context: String)
    func changeGroup(groupContext: String)
    func goBack()
    func goNext()
    func store()
    func delete()
}

final class PageHistoryDataModel: PageHistoryDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<PageHistoryDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<PageHistoryDataModelError>()

    static let s = PageHistoryDataModel()

    private let repository = UserDefaultRepository()

    /// webViewそれぞれの履歴とカレントページインデックス
    var pageGroupList: PageGroupList
    public private(set) var histories: [PageHistory] {
        get {
            return pageGroupList.currentGroup.histories
        }
        set(value) {
            pageGroupList.currentGroup.histories = value
        }
    }

    /// 現在表示しているwebviewのコンテキスト
    var currentContext: String {
        get {
            return pageGroupList.currentGroup.currentContext
        }
        set(value) {
            log.debug("current context changed. \(currentContext) -> \(value)")
            pageGroupList.currentGroup.currentContext = value
        }
    }

    /// 現在のページ情報
    var currentHistory: PageHistory? {
        return histories.find({ $0.context == currentContext })
    }

    /// 現在の位置
    var currentLocation: Int? {
        return histories.index(where: { $0.context == currentContext })
    }

    /// 現在のデータ
    private var currentData: (pageHistory: PageHistory, index: Int)? {
        if let currentHistory = self.currentHistory, let currentLocation = self.currentLocation {
            return (pageHistory: currentHistory, index: currentLocation)
        } else {
            return nil
        }
    }

    /// 最新ページを見ているかフラグ
    private var isViewingLatest: Bool {
        return currentLocation == histories.count - 1
    }

    /// ページヒストリー保存件数
    private let pageHistorySaveCount = UserDefaultRepository().get(key: .pageHistorySaveCount)

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    private init() {
        // pageHistory読み込み
        let result = localStorageRepository.getData(.pageHistory)
        if case let .success(data) = result {
            if let pageGroupList = NSKeyedUnarchiver.unarchiveObject(with: data) as? PageGroupList {
                self.pageGroupList = pageGroupList
            } else {
                self.pageGroupList = PageGroupList()
                log.error("unarchive histories error.")
            }
        } else {
            pageGroupList = PageGroupList()
        }
    }

    /// 初期化
    private func initialize() {
        // pageHistory読み込み
        let result = localStorageRepository.getData(.pageHistory)
        if case let .success(data) = result {
            if let pageGroupList = NSKeyedUnarchiver.unarchiveObject(with: data) as? PageGroupList {
                self.pageGroupList = pageGroupList
            } else {
                self.pageGroupList = PageGroupList()
                log.error("unarchive histories error.")
            }
        } else {
            pageGroupList = PageGroupList()
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
            rx_action.onNext(.startLoading(context: context))
        }
    }

    /// ロード終了
    func endLoading(context: String) {
        if let history = histories.find({ $0.context == context }) {
            history.isLoading = false
            rx_action.onNext(.endLoading(context: context))
        } else {
            log.error("pageHistoryDataModelDidEndLoading not fired. history is deleted.")
        }
    }

    /// 描画終了
    func endRendering(context: String) {
        if histories.find({ $0.context == context }) != nil {
            rx_action.onNext(.endRendering(context: context))
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

    /// タブの入れ替え
    func swap(start: Int, end: Int) {
        histories = histories.move(from: start, to: end)
        rx_action.onNext(.swap(start: start, end: end))
    }

    /// update url with context
    func updateUrl(context: String, url: String, operation: PageHistory.Operation) -> Bool {
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
            return true
        } else {
            return false
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
                let before = currentData!
                let newPage = PageHistory(url: url ?? "", title: title ?? "")
                histories.insert(newPage, at: currentLocation + 1)
                currentContext = newPage.context
                rx_action.onNext(.insert(before: before, after: currentData!))
            }
        }
    }

    /// add page
    func append(url: String? = nil, title: String? = nil) {
        let before = currentData
        let newPage = PageHistory(url: url ?? "", title: title ?? "")
        histories.append(newPage)
        currentContext = newPage.context
        rx_action.onNext(.append(before: before, after: currentData!))
    }

    /// タブグループ作成
    func appendGroup() {
        let pageGroup = PageGroup()
        pageGroupList.groups.append(pageGroup)
        rx_action.onNext(.appendGroup)
    }

    /// タブグループタイトル変更
    func changeGroupTitle(groupContext: String, title: String) {
        if let targetGroup = pageGroupList.groups.find({ $0.groupContext == groupContext }) {
            if targetGroup.title != title {
                targetGroup.title = title
                rx_action.onNext(.changeGroupTitle(groupContext: groupContext, title: title))
            }
        }
    }

    /// タブグループ削除
    func removeGroup(groupContext: String) {
        if let deleteIndex = pageGroupList.groups.index(where: { $0.groupContext == groupContext }) {
            let isCurrentDelete = groupContext == pageGroupList.currentGroupContext

            pageGroupList.groups.remove(at: deleteIndex)

            // 削除後にデータなし
            let isAllDelete = pageGroupList.groups.count == 0
            if isAllDelete {
                pageGroupList = PageGroupList()
            } else if isCurrentDelete {
                // 最後の要素を削除した場合は、前のページに戻る
                if deleteIndex == pageGroupList.groups.count {
                    pageGroupList.currentGroupContext = pageGroupList.groups[deleteIndex - 1].groupContext
                } else {
                    pageGroupList.currentGroupContext = pageGroupList.groups[deleteIndex].groupContext
                }
            }
            rx_action.onNext(.deleteGroup(groupContext: groupContext))

            if isCurrentDelete || isAllDelete {
                rebuild()
            }
            store()
        }
    }

    /// change private mode
    func invertPrivateMode(groupContext: String) {
        if let targetGroup = pageGroupList.groups.find({ $0.groupContext == groupContext }) {
            let isCurrentInvert = groupContext == pageGroupList.currentGroupContext

            targetGroup.isPrivate = !targetGroup.isPrivate

            if isCurrentInvert && targetGroup.isPrivate {
                rebuild()
            }

            rx_action.onNext(.invertPrivateMode)
        }
    }

    /// ページコピー
    func copy() {
        if let currentHistory = currentHistory {
            if isViewingLatest {
                // 最新ページを見ているなら、insertではないので、appendに切り替える
                append(url: currentHistory.url, title: currentHistory.title)
            } else {
                insert(url: currentHistory.url, title: currentHistory.title)
            }
        }
    }

    /// ページリロード
    func reload() {
        rx_action.onNext(.reload)
    }

    /// ヒストリー再構築
    func rebuild() {
        // フッターから構築しないと、ローディングアニメーションが動かない
        rx_action.onNext(.rebuildThumbnail)
        rx_action.onNext(.rebuild)
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
                    rx_action.onNext(.delete(isFront: true, deleteContext: context, currentContext: nil, deleteIndex: deleteIndex))
                    append()
                    return
                } else {
                    // 最後の要素を削除した場合は、前のページに戻る
                    if deleteIndex == histories.count {
                        currentContext = histories[deleteIndex - 1].context
                    } else {
                        currentContext = histories[deleteIndex].context
                    }

                    rx_action.onNext(.delete(isFront: true, deleteContext: context, currentContext: currentContext, deleteIndex: deleteIndex))
                }
            } else {
                histories.remove(at: deleteIndex)
                rx_action.onNext(.delete(isFront: false, deleteContext: context, currentContext: currentContext, deleteIndex: deleteIndex))
            }
        } else {
            log.error("cannot find delete context.")
        }
    }

    /// 表示中ページの変更
    func change(context: String) {
        guard currentContext != context else {
            log.debug("change front faild. same page")
            return
        }
        let before = currentData!
        currentContext = context
        rx_action.onNext(.change(before: before, after: currentData!))
    }

    /// 表示中グループの変更
    func changeGroup(groupContext: String) {
        if let selectedGroup = pageGroupList.groups.find({ $0.groupContext == groupContext }) {
            pageGroupList.currentGroupContext = selectedGroup.groupContext
            rebuild()
        } else {
            log.warning("selected same group.")
        }
    }

    /// 前ページに変更
    func goBack() {
        if let currentLocation = currentLocation, histories.count > 0 {
            let before = currentData!
            let targetContext = histories[0 ... histories.count - 1 ~= currentLocation - 1 ? currentLocation - 1 : histories.count - 1].context
            currentContext = targetContext
            rx_action.onNext(.change(before: before, after: currentData!))
        }
    }

    /// 次ページに変更
    func goNext() {
        if let currentLocation = currentLocation, histories.count > 0 {
            let before = currentData!
            let targetContext = histories[0 ... histories.count - 1 ~= currentLocation + 1 ? currentLocation + 1 : 0].context
            currentContext = targetContext
            rx_action.onNext(.change(before: before, after: currentData!))
        }
    }

    /// タブ情報の保存
    func store() {
        let pageGroupListData = NSKeyedArchiver.archivedData(withRootObject: pageGroupList)
        let result = localStorageRepository.write(.pageHistory, data: pageGroupListData)

        if case .failure = result {
            // ハンドリングしない
//            rx_error.onNext(.store)
        }
    }

    /// 全データの削除
    func delete() {
        pageGroupList.groups.removeAll()
        pageGroupList = PageGroupList()
        let result = localStorageRepository.delete(.pageHistory)

        if case .failure = result {
            rx_error.onNext(.delete)
        }
    }
}
