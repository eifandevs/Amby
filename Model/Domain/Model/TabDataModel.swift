//
//  TabModel.swift
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

enum TabDataModelAction {
    case insert(before: (tab: Tab, index: Int), after: (tab: Tab, index: Int))
    case append(before: (tab: Tab, index: Int)?, after: (tab: Tab, index: Int))
    case appendGroup
    case changeGroupTitle(groupContext: String, title: String)
    case deleteGroup(groupContext: String)
    case invertPrivateMode
    case change(before: (tab: Tab, index: Int), after: (tab: Tab, index: Int))
    case delete(isFront: Bool, deleteContext: String, currentContext: String?, deleteIndex: Int)
    case swap(start: Int, end: Int)
    case rebuild
    case rebuildThumbnail
    case load(url: String)
    case startLoading(context: String)
    case endLoading(context: String)
    case endRendering(context: String)
    case fetch(tabGroupList: TabGroupList)
}

enum TabDataModelError {
    case delete
    case store
    case fetch
}

extension TabDataModelError: ModelError {
    var message: String {
        switch self {
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_TAB_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_TAB_ERROR
        case .fetch:
            return MessageConst.NOTIFICATION.FETCH_TAB_ERROR
        }
    }
}

protocol TabDataModelProtocol {
    var rx_action: PublishSubject<TabDataModelAction> { get }
    var rx_error: PublishSubject<TabDataModelError> { get }
    var tabGroupList: TabGroupList { get }
    var currentContext: String { get set }
    var histories: [Tab] { get }
    var currentTab: Tab? { get }
    var currentLocation: Int? { get }
    var isPrivate: Bool { get }
    func initialize()
    func getHistory(context: String) -> Tab?
    func getHistory(index: Int) -> Tab?
    func getIsLoading(context: String) -> Bool?
    func startLoading(context: String)
    func endLoading(context: String)
    func endRendering(context: String)
    func swap(start: Int, end: Int)
    func updateUrl(context: String, url: String)
    func updateTitle(context: String, title: String)
    func updateSession(context: String, urls: [String], currentPage: Int)
    func insert(url: String?, title: String?)
    func append(url: String?, title: String?)
    func appendGroup()
    func changeGroupTitle(groupContext: String, title: String)
    func removeGroup(groupContext: String)
    func invertPrivateMode(groupContext: String)
    func copy()
    func rebuild()
    func getIndex(context: String) -> Int?
    func remove(context: String)
    func change(context: String)
    func changeGroup(groupContext: String)
    func goBack()
    func goNext()
    func store()
    func delete()
    func fetch(request: GetTabRequest)
}

final class TabDataModel: TabDataModelProtocol {
    /// アクション通知用RX
    let rx_action = PublishSubject<TabDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<TabDataModelError>()

    /// 更新有無フラグ(更新されていればサーバーと同期する)
    var isUpdated = false
    
    static let s = TabDataModel()

    private let repository = UserDefaultRepository()

    private let disposeBag = DisposeBag()

    /// webViewそれぞれの履歴とカレントページインデックス
    var tabGroupList = TabGroupList()
    public private(set) var histories: [Tab] {
        get {
            return tabGroupList.currentGroup.histories
        }
        set(value) {
            tabGroupList.currentGroup.histories = value
        }
    }

    /// 現在表示しているwebviewのコンテキスト
    var currentContext: String {
        get {
            return tabGroupList.currentGroup.currentContext
        }
        set(value) {
            if let deleteIndex = tabGroupList.currentGroup.backForwardContextList.index(where: { $0 == value }) {
                tabGroupList.currentGroup.backForwardContextList.remove(at: deleteIndex)
            }
            tabGroupList.currentGroup.backForwardContextList.append(value)
            log.debug("current context changed. \(currentContext) -> \(value)")
            log.debug("current group backforwardlist: \(tabGroupList.currentGroup.backForwardContextList)")
            tabGroupList.currentGroup.currentContext = value
        }
    }

    /// 現在のページ情報
    var currentTab: Tab? {
        return histories.find({ $0.context == currentContext })
    }

    /// 現在の位置
    var currentLocation: Int? {
        return histories.index(where: { $0.context == currentContext })
    }

    /// 現在の閲覧モード
    var isPrivate: Bool {
        return tabGroupList.currentGroup.isPrivate
    }

    /// 現在のデータ
    private var currentData: (tab: Tab, index: Int)? {
        if let currentTab = self.currentTab, let currentLocation = self.currentLocation {
            return (tab: currentTab, index: currentLocation)
        } else {
            return nil
        }
    }

    /// 最新ページを見ているかフラグ
    private var isViewingLatest: Bool {
        return currentLocation == histories.count - 1
    }

    /// ページヒストリー保存件数
    private let tabSaveCount = UserDefaultRepository().get(key: .tabSaveCount)

    /// local storage repository
    private let localStorageRepository = LocalStorageRepository<Cache>()

    private init() {}

    /// 初期化
    func initialize() {
        // tab読み込み
        let result = localStorageRepository.getData(.tab)
        if case let .success(data) = result {
            if let tabGroupList = NSKeyedUnarchiver.unarchiveObject(with: data) as? TabGroupList {
                self.tabGroupList = tabGroupList
            } else {
                self.tabGroupList = TabGroupList()
                log.error("unarchive histories error.")
            }
        } else {
            tabGroupList = TabGroupList()
        }
    }

    /// get the history with context
    func getHistory(context: String) -> Tab? {
        return histories.find({ $0.context == context })
    }

    /// get the history with index
    func getHistory(index: Int) -> Tab? {
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
            log.error("tabDataModelDidEndLoading not fired. history is deleted.")
        }
    }

    /// 描画終了
    func endRendering(context: String) {
        if histories.find({ $0.context == context }) != nil {
            rx_action.onNext(.endRendering(context: context))
        } else {
            log.error("tabDataModelDidEndRendering not fired. history is deleted.")
        }
    }

    /// タブの入れ替え
    func swap(start: Int, end: Int) {
        histories = histories.move(from: start, to: end)
        rx_action.onNext(.swap(start: start, end: end))
    }

    /// update url with context
    func updateUrl(context: String, url: String) {
        if !url.isEmpty && url.isValidUrl {
            histories.forEach({
                if $0.context == context {
                    $0.url = url
                    log.debug("save page history url. url: \(url)")

                    return
                }
            })
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

    /// update session
    func updateSession(context: String, urls: [String], currentPage: Int) {
        histories.forEach({
            if $0.context == context {
                $0.session = Session(urls: urls, currentPage: currentPage)
                return
            }
        })
    }

    /// ページ挿入(new window event)
    func insert(url: String?, title: String? = nil) {
        if isViewingLatest {
            // 最新ページを見ているなら、insertではないので、appendに切り替える
            append(url: url, title: title ?? "")
        } else {
            if let currentLocation = currentLocation {
                let before = currentData!
                let newPage = Tab(url: url ?? "", title: title ?? "")
                histories.insert(newPage, at: currentLocation + 1)
                currentContext = newPage.context
                rx_action.onNext(.insert(before: before, after: currentData!))
            }
        }
    }

    /// add page
    func append(url: String? = nil, title: String? = nil) {
        let before = currentData
        let newPage = Tab(url: url ?? "", title: title ?? "")
        histories.append(newPage)
        currentContext = newPage.context
        rx_action.onNext(.append(before: before, after: currentData!))
    }

    /// タブグループ作成
    func appendGroup() {
        let tabGroup = TabGroup()
        tabGroupList.groups.append(tabGroup)
        rx_action.onNext(.appendGroup)
    }

    /// タブグループタイトル変更
    func changeGroupTitle(groupContext: String, title: String) {
        if let targetGroup = tabGroupList.groups.find({ $0.groupContext == groupContext }) {
            if targetGroup.title != title {
                targetGroup.title = title
                rx_action.onNext(.changeGroupTitle(groupContext: groupContext, title: title))
            }
        }
    }

    /// タブグループ削除
    func removeGroup(groupContext: String) {
        if let deleteIndex = tabGroupList.groups.index(where: { $0.groupContext == groupContext }) {
            let isCurrentDelete = groupContext == tabGroupList.currentGroupContext

            tabGroupList.groups.remove(at: deleteIndex)

            // 削除後にデータなし
            let isAllDelete = tabGroupList.groups.count == 0
            if isAllDelete {
                tabGroupList = TabGroupList()
            } else if isCurrentDelete {
                // 最後の要素を削除した場合は、前のページに戻る
                if deleteIndex == tabGroupList.groups.count {
                    tabGroupList.currentGroupContext = tabGroupList.groups[deleteIndex - 1].groupContext
                } else {
                    tabGroupList.currentGroupContext = tabGroupList.groups[deleteIndex].groupContext
                }
            }
            rx_action.onNext(.deleteGroup(groupContext: groupContext))

            if isCurrentDelete || isAllDelete {
                rebuild()
            }
        }
    }

    /// change private mode
    func invertPrivateMode(groupContext: String) {
        if let targetGroup = tabGroupList.groups.find({ $0.groupContext == groupContext }) {
            let isCurrentInvert = groupContext == tabGroupList.currentGroupContext

            targetGroup.isPrivate = !targetGroup.isPrivate

            if isCurrentInvert && targetGroup.isPrivate {
                rebuild()
            }

            rx_action.onNext(.invertPrivateMode)
        }
    }

    /// ページコピー
    func copy() {
        if let currentTab = currentTab {
            if isViewingLatest {
                // 最新ページを見ているなら、insertではないので、appendに切り替える
                append(url: currentTab.url, title: currentTab.title)
            } else {
                insert(url: currentTab.url, title: currentTab.title)
            }
        }
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
        if let selectedGroup = tabGroupList.groups.find({ $0.groupContext == groupContext }) {
            tabGroupList.currentGroupContext = selectedGroup.groupContext
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
        let tabGroupListData = NSKeyedArchiver.archivedData(withRootObject: tabGroupList)
        let result = localStorageRepository.write(.tab, data: tabGroupListData)

        if case .failure = result {
            // ハンドリングしない
//            rx_error.onNext(.store)
        }
    }

    /// 全データの削除
    func delete() {
        tabGroupList.groups.removeAll()
        tabGroupList = TabGroupList()
        let result = localStorageRepository.delete(.tab)

        if case .failure = result {
            rx_error.onNext(.delete)
        }
    }

    /// 記事取得
    func fetch(request: GetTabRequest) {
        let repository = ApiRepository<App>()

        repository.rx.request(.getTabData(request: request))
            .observeOn(MainScheduler.asyncInstance)
            .map { (response) -> GetTabResponse? in

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let tabDataResponse: GetTabResponse = try decoder.decode(GetTabResponse.self, from: response.data)
                    return tabDataResponse
                } catch {
                    return nil
                }
            }
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let `self` = self else { return }
                    if let response = response, response.code == ModelConst.APP_STATUS_CODE.NORMAL {
                        log.debug("get tab success.")
                        let tabGroupList = response.data
                        self.tabGroupList = tabGroupList
                        self.store()
                        self.rx_action.onNext(.fetch(tabGroupList: tabGroupList))
                    } else {
                        log.error("get tab error. code: \(response?.code ?? "")")
                        self.rx_error.onNext(.fetch)
                    }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    log.error("get tab error. error: \(error.localizedDescription)")
                    self.rx_error.onNext(.fetch)
            })
            .disposed(by: disposeBag)
    }
}
