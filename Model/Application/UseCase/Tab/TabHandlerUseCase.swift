//
//  TabHandlerUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum TabHandlerUseCaseAction {
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
public final class TabHandlerUseCase {
    public static let s = TabHandlerUseCase()
    /// アクション通知用RX
    public let rx_action = PublishSubject<TabHandlerUseCaseAction>()

    public var currentUrl: String? {
        return tabDataModel.currentTab?.url
    }

    public var currentSession: Session? {
        return tabDataModel.currentTab?.session
    }

    public var tabGroupList: TabGroupList {
        return tabDataModel.tabGroupList
    }

    public var tabs: [Tab] {
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

    // usecase
    private let storeTabUseCase = StoreTabUseCase()

    // models
    private var tabDataModel: TabDataModelProtocol!
    private var favoriteDataModel: FavoriteDataModelProtocol!
    private var progressDataModel: ProgressDataModelProtocol!

    private init() {
        setupProtocolImpl()
        setupRx()
    }

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
                self.storeTabUseCase.exe()
            }
            .disposed(by: disposeBag)
    }

    /// タブグループたタイトル編集画面表示要求
    public func presentGroupTitleEdit(groupContext: String) {
        rx_action.onNext(.presentGroupTitleEdit(groupContext: groupContext))
    }

    /// リロード
    public func reload() {
        self.rx_action.onNext(.reload)
    }

    /// 前ページに切り替え
    public func historyBack() {
        rx_action.onNext(.historyBack)
    }

    /// 後ページに切り替え
    public func historyForward() {
        rx_action.onNext(.historyForward)
    }
}
