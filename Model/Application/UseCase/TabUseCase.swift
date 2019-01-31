//
//  TabUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum TabUseCaseAction {
    case insert(before: (pageHistory: PageHistory, index: Int), after: (pageHistory: PageHistory, index: Int))
    case append(before: (pageHistory: PageHistory, index: Int)?, after: (pageHistory: PageHistory, index: Int))
    case change(before: (pageHistory: PageHistory, index: Int), after: (pageHistory: PageHistory, index: Int))
    case reload
    case rebuild
    case delete(isFront: Bool, deleteContext: String, currentContext: String?, deleteIndex: Int)
    case swap(start: Int, end: Int)
    case startLoading(context: String)
    case endLoading(context: String, title: String)
    case endRendering(context: String)
}

/// タブユースケース
public final class TabUseCase {
    public static let s = TabUseCase()
    /// アクション通知用RX
    public let rx_action = PublishSubject<TabUseCaseAction>()

    public var currentUrl: String? {
        return pageHistoryDataModel.currentHistory?.url
    }

    public var pageHistories: [PageHistory] {
        return pageHistoryDataModel.histories
    }

    public var currentHistory: PageHistory? {
        return pageHistoryDataModel.currentHistory
    }

    public var currentContext: String {
        return pageHistoryDataModel.currentContext
    }

    public var currentLocation: Int? {
        return pageHistoryDataModel.currentLocation
    }

    public var currentTabCount: Int {
        return pageHistoryDataModel.histories.count
    }

    // models
    private var pageHistoryDataModel: PageHistoryDataModelProtocol!
    private var favoriteDataModel: FavoriteDataModelProtocol!
    private var progressDataModel: ProgressDataModelProtocol!

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private func setupProtocolImpl() {
        pageHistoryDataModel = PageHistoryDataModel.s
        favoriteDataModel = FavoriteDataModel.s
        progressDataModel = ProgressDataModel.s
    }

    private func setupRx() {
        // インサート監視
        pageHistoryDataModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .insert(before, after): self.rx_action.onNext(.insert(before: before, after: after))
                case .reload: self.rx_action.onNext(.reload)
                case .rebuild: self.rx_action.onNext(.rebuild)
                case let .append(before, after): self.rx_action.onNext(.append(before: before, after: after))
                case let .change(before, after): self.rx_action.onNext(.change(before: before, after: after))
                case let .delete(isFront, deleteContext, currentContext, deleteIndex):
                    self.rx_action.onNext(.delete(isFront: isFront, deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex))
                case let .swap(start, end): self.rx_action.onNext(.swap(start: start, end: end))
                case let .startLoading(context): self.rx_action.onNext(.startLoading(context: context))
                case let .endLoading(context):
                    if let isLoading = self.pageHistoryDataModel.getIsLoading(context: context) {
                        if !isLoading {
                            // When loading is completed and loading has started while saving thumbnails, skip
                            if let pageHistory = self.pageHistoryDataModel.getHistory(context: context) {
                                self.rx_action.onNext(.endLoading(context: context, title: pageHistory.title))
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
    }

    /// 現在のタブをクローズ
    public func close() {
        pageHistoryDataModel.remove(context: pageHistoryDataModel.currentContext)
        store()
    }

    /// 全てのタブをクローズ
    public func closeAll() {
        let histories = pageHistoryDataModel.histories
        histories.forEach { pageHistory in
            self.pageHistoryDataModel.remove(context: pageHistory.context)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.25))
        }
        store()
    }

    /// 現在のタブをコピー
    public func copy() {
        pageHistoryDataModel.copy()
        store()
    }

    /// タブ入れ替え
    public func swap(start: Int, end: Int) {
        pageHistoryDataModel.swap(start: start, end: end)
        store()
    }

    /// 現在のタブを削除
    public func remove() {
        pageHistoryDataModel.remove(context: pageHistoryDataModel.currentContext)
        store()
    }

    /// 特定のタブを削除
    public func remove(context: String) {
        pageHistoryDataModel.remove(context: context)
        store()
    }

    /// タブ変更
    public func change(context: String) {
        pageHistoryDataModel.change(context: context)
    }

    /// タブの追加
    public func add(url: String? = nil) {
        pageHistoryDataModel.append(url: url, title: nil)
        store()
    }

    /// タブの挿入
    public func insert(url: String? = nil) {
        pageHistoryDataModel.insert(url: url, title: nil)
        store()
    }

    /// タブの全削除
    public func delete() {
        pageHistoryDataModel.delete()
        store()
    }

    /// ページインデックス取得
    public func getIndex(context: String) -> Int? {
        return pageHistoryDataModel.getIndex(context: context)
    }

    /// 履歴取得
    public func getHistory(index: Int) -> PageHistory? {
        return pageHistoryDataModel.getHistory(index: index)
    }

    /// 直近URL取得
    public func getMostForwardUrl(context: String) -> String? {
        return pageHistoryDataModel.getMostForwardUrl(context: context)
    }

    /// 過去ページ閲覧中フラグ取得
    public func getIsPastViewing(context: String) -> Bool? {
        return pageHistoryDataModel.isPastViewing(context: context)
    }

    /// 前回URL取得
    public func getBackUrl(context: String) -> String? {
        return pageHistoryDataModel.getBackUrl(context: context)
    }

    /// 次URL取得
    public func getForwardUrl(context: String) -> String? {
        return pageHistoryDataModel.getForwardUrl(context: context)
    }

    public func startLoading(context: String) {
        pageHistoryDataModel.startLoading(context: context)
    }

    public func endLoading(context: String) {
        pageHistoryDataModel.endLoading(context: context)
    }

    public func endRendering(context: String) {
        pageHistoryDataModel.endRendering(context: context)
        store()
    }

    public func updateProgress(object: CGFloat) {
        progressDataModel.updateProgress(progress: object)
    }

    /// 前WebViewに切り替え
    public func goBack() {
        pageHistoryDataModel.goBack()
    }

    /// 後WebViewに切り替え
    public func goNext() {
        pageHistoryDataModel.goNext()
    }

    /// update url in page history
    public func updateUrl(context: String, url: String, operation: PageHistory.Operation) {
        if pageHistoryDataModel.updateUrl(context: context, url: url, operation: operation) {
            progressDataModel.updateText(text: url)
            if let currentHistory = pageHistoryDataModel.currentHistory {
                favoriteDataModel.reload(currentHistory: currentHistory)
            }
        }
    }

    /// update title in page history
    public func updateTitle(context: String, title: String) {
        pageHistoryDataModel.updateTitle(context: context, title: title)
    }

    /// 閲覧、ページ履歴の永続化
    private func store() {
        DispatchQueue(label: ModelConst.APP.QUEUE).async {
            self.pageHistoryDataModel.store()
        }
    }
}
