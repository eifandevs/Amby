//
//  TabUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum TabUseCaseAction {
    case insert(before: (tab: Tab, index: Int), after: (tab: Tab, index: Int))
    case append(before: (tab: Tab, index: Int)?, after: (tab: Tab, index: Int))
    case appendGroup
    case changeGroupTitle(groupContext: String, title: String)
    case deleteGroup(groupContext: String)
    case invertPrivateMode
    case change(before: (tab: Tab, index: Int), after: (tab: Tab, index: Int))
    case reload
    case rebuild
    case rebuildThumbnail
    case delete(isFront: Bool, deleteContext: String, currentContext: String?, deleteIndex: Int)
    case swap(start: Int, end: Int)
    case startLoading(context: String)
    case endLoading(context: String, title: String)
    case endRendering(context: String)
    case presentGroupTitleEdit(groupContext: String)
    case historyBack
    case historyForward
}

/// タブユースケース
public final class TabUseCase {
    public static let s = TabUseCase()
    /// アクション通知用RX
    public let rx_action = PublishSubject<TabUseCaseAction>()

    public var currentUrl: String? {
        return tabDataModel.currentTab?.url
    }

    public var tabGroupList: TabGroupList {
        return tabDataModel.tabGroupList
    }

    public var pageHistories: [Tab] {
        return tabDataModel.histories
    }

    public var currentTab: Tab? {
        return tabDataModel.currentTab
    }

    public var currentContext: String {
        return tabDataModel.currentContext
    }

    public var currentLocation: Int? {
        return tabDataModel.currentLocation
    }

    public var currentTabCount: Int {
        return tabDataModel.histories.count
    }

    // models
    private var tabDataModel: TabDataModelProtocol!
    private var favoriteDataModel: FavoriteDataModelProtocol!
    private var progressDataModel: ProgressDataModelProtocol!

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private func setupProtocolImpl() {
        tabDataModel = TabDataModel.s
        favoriteDataModel = FavoriteDataModel.s
        progressDataModel = ProgressDataModel.s
    }

    private func setupRx() {
        // インサート監視
        tabDataModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .insert(before, after): self.rx_action.onNext(.insert(before: before, after: after))
                case .rebuild: self.rx_action.onNext(.rebuild)
                case .rebuildThumbnail: self.rx_action.onNext(.rebuildThumbnail)
                case let .append(before, after): self.rx_action.onNext(.append(before: before, after: after))
                case .appendGroup: self.rx_action.onNext(.appendGroup)
                case let .changeGroupTitle(groupContext, title): self.rx_action.onNext(.changeGroupTitle(groupContext: groupContext, title: title))
                case let .deleteGroup(groupContext): self.rx_action.onNext(.deleteGroup(groupContext: groupContext))
                case .invertPrivateMode: self.rx_action.onNext(.invertPrivateMode)
                case let .change(before, after): self.rx_action.onNext(.change(before: before, after: after))
                case let .delete(isFront, deleteContext, currentContext, deleteIndex):
                    self.rx_action.onNext(.delete(isFront: isFront, deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex))
                case let .swap(start, end): self.rx_action.onNext(.swap(start: start, end: end))
                case let .startLoading(context): self.rx_action.onNext(.startLoading(context: context))
                case let .endLoading(context):
                    if let isLoading = self.tabDataModel.getIsLoading(context: context) {
                        if !isLoading {
                            // When loading is completed and loading has started while saving thumbnails, skip
                            if let tab = self.tabDataModel.getHistory(context: context) {
                                self.rx_action.onNext(.endLoading(context: context, title: tab.title))
                            }
                        } else {
                            log.warning("start loading while saving thumbnails.")
                        }
                    }
                case let .endRendering(context): self.rx_action.onNext(.endRendering(context: context))
                default: break
                }
            }
            .disposed(by: disposeBag)

        // バックグラウンド時にタブ情報を保存
        NotificationCenter.default.rx.notification(.UIApplicationWillResignActive, object: nil)
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                self.store()
            }
            .disposed(by: disposeBag)
    }

    /// タブ初期化
    public func initialize() {
        tabDataModel.initialize()
    }

    /// タブグループたタイトル編集画面表示要求
    public func presentGroupTitleEdit(groupContext: String) {
        rx_action.onNext(.presentGroupTitleEdit(groupContext: groupContext))
    }

    /// 現在のタブをクローズ
    public func close() {
        tabDataModel.remove(context: tabDataModel.currentContext)
    }

    /// 全てのタブをクローズ
    public func closeAll() {
        let histories = tabDataModel.histories
        histories.forEach { tab in
            self.tabDataModel.remove(context: tab.context)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.25))
        }
    }

    /// リロード
    public func reload() {
        self.rx_action.onNext(.reload)
    }

    /// 現在のタブをコピー
    public func copy() {
        tabDataModel.copy()
    }

    /// タブ入れ替え
    public func swap(start: Int, end: Int) {
        tabDataModel.swap(start: start, end: end)
    }

    /// 現在のタブを削除
    public func remove() {
        tabDataModel.remove(context: tabDataModel.currentContext)
    }

    /// 特定のタブを削除
    public func remove(context: String) {
        tabDataModel.remove(context: context)
    }

    /// タブ変更
    public func change(context: String) {
        tabDataModel.change(context: context)
    }

    /// グループ変更
    public func changeGroup(groupContext: String) {
        tabDataModel.changeGroup(groupContext: groupContext)
    }

    /// グループのタイトル変更
    public func changeGroupTitle(groupContext: String, title: String) {
        tabDataModel.changeGroupTitle(groupContext: groupContext, title: title)
    }

    /// グループ削除
    public func deleteGroup(groupContext: String) {
        tabDataModel.removeGroup(groupContext: groupContext)
    }

    /// タブの追加
    public func add(url: String? = nil) {
        tabDataModel.append(url: url, title: nil)
    }

    /// グループの追加
    public func addGroup() {
        tabDataModel.appendGroup()
    }

    /// タブの挿入
    public func insert(url: String? = nil) {
        tabDataModel.insert(url: url, title: nil)
    }

    /// タブの全削除
    public func delete() {
        tabDataModel.delete()
    }

    /// タブ情報再構築
    public func rebuild() {
        tabDataModel.rebuild()
    }

    /// ページインデックス取得
    public func getIndex(context: String) -> Int? {
        return tabDataModel.getIndex(context: context)
    }

    /// 履歴取得
    public func getHistory(index: Int) -> Tab? {
        return tabDataModel.getHistory(index: index)
    }

    public func startLoading(context: String) {
        tabDataModel.startLoading(context: context)
    }

    public func endLoading(context: String) {
        tabDataModel.endLoading(context: context)
    }

    public func endRendering(context: String) {
        tabDataModel.endRendering(context: context)
    }

    public func updateProgress(object: CGFloat) {
        progressDataModel.updateProgress(progress: object)
    }

    /// 前WebViewに切り替え
    public func goBack() {
        tabDataModel.goBack()
    }

    /// 後WebViewに切り替え
    public func goNext() {
        tabDataModel.goNext()
    }

    /// 前ページに切り替え
    public func historyBack() {
        rx_action.onNext(.historyBack)
    }

    /// 後ページに切り替え
    public func historyForward() {
        rx_action.onNext(.historyForward)
    }

    /// update url in page history
    public func updateUrl(context: String, url: String) {
        if !url.isEmpty && url.isValidUrl {
            tabDataModel.updateUrl(context: context, url: url)
            if let currentTab = currentTab, context == currentContext {
                progressDataModel.updateText(text: url)
                favoriteDataModel.reload(currentTab: currentTab)
            }
        }
    }

    /// update title in page history
    public func updateTitle(context: String, title: String) {
        tabDataModel.updateTitle(context: context, title: title)
    }

    /// update session
    public func updateSession(context: String, urls: [String], currentPage: Int) {
        tabDataModel.updateSession(context: context, urls: urls, currentPage: currentPage)
    }

    /// change private mode
    public func invertPrivateMode(groupContext: String) {
        if PasscodeUseCase.s.authentificationChallenge() {
            tabDataModel.invertPrivateMode(groupContext: groupContext)
        }
    }

    /// 閲覧、ページ履歴の永続化
    private func store() {
        DispatchQueue(label: ModelConst.APP.QUEUE).async {
            self.tabDataModel.store()
        }
    }
}
