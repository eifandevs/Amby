//
//  TabUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum TabUseCaseAction {
    case insert(at: Int)
    case reload
    case append
    case change
    case delete(deleteContext: String, currentContext: String?, deleteIndex: Int)
    case startLoading(context: String)
    case endLoading(context: String, title: String)
}

/// タブユースケース
public final class TabUseCase {
    public static let s = TabUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<TabUseCaseAction>()

    public var currentUrl: String? {
        return PageHistoryDataModel.s.currentHistory?.url
    }

    public var pageHistories: [PageHistory] {
        return PageHistoryDataModel.s.histories
    }

    public var currentHistory: PageHistory? {
        return PageHistoryDataModel.s.currentHistory
    }

    public var currentContext: String {
        return PageHistoryDataModel.s.currentContext
    }

    public var currentLocation: Int? {
        return PageHistoryDataModel.s.currentLocation
    }

    public var currentTabCount: Int {
        return PageHistoryDataModel.s.histories.count
    }

    private init() {
        setupRx()
    }

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private func setupRx() {
        // インサート監視
        PageHistoryDataModel.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self else { return }
                if let action = action.element {
                    switch action {
                    case let .insert(_, at):
                        self.rx_action.onNext(.insert(at: at))
                    case .reload: self.rx_action.onNext(.reload)
                    case .append: self.rx_action.onNext(.append)
                    case .change: self.rx_action.onNext(.change)
                    case let .delete(deleteContext, currentContext, deleteIndex):
                        self.rx_action.onNext(.delete(deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex))
                    case let .startLoading(context): self.rx_action.onNext(.startLoading(context: context))
                    case let .endLoading(context):
                        if let isLoading = PageHistoryDataModel.s.getIsLoading(context: context) {
                            if !isLoading {
                                // When loading is completed and loading has started while saving thumbnails, skip
                                if let pageHistory = PageHistoryDataModel.s.getHistory(context: context) {
                                    self.rx_action.onNext(.endLoading(context: context, title: pageHistory.title))
                                }
                            } else {
                                log.warning("start loading while saving thumbnails.")
                            }
                        }
                    default: break
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    /// 現在のタブをクローズ
    public func close() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
        store()
    }

    /// 全てのタブをクローズ
    public func closeAll() {
        let histories = PageHistoryDataModel.s.histories
        histories.forEach { pageHistory in
            PageHistoryDataModel.s.remove(context: pageHistory.context)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.25))
        }
        store()
    }

    /// 現在のタブをコピー
    public func copy() {
        PageHistoryDataModel.s.copy()
        store()
    }

    /// 現在のタブを削除
    public func remove() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
        store()
    }

    /// 特定のタブを削除
    public func remove(context: String) {
        PageHistoryDataModel.s.remove(context: context)
        store()
    }

    /// タブ変更
    public func change(context: String) {
        PageHistoryDataModel.s.change(context: context)
    }

    /// タブの追加
    public func add(url: String? = nil) {
        PageHistoryDataModel.s.append(url: url)
        store()
    }

    /// タブの挿入
    public func insert(url: String? = nil) {
        PageHistoryDataModel.s.insert(url: url)
        store()
    }

    /// タブの全削除
    public func delete() {
        PageHistoryDataModel.s.delete()
        store()
    }

    /// ページインデックス取得
    public func getIndex(context: String) -> Int? {
        return PageHistoryDataModel.s.getIndex(context: context)
    }

    /// 履歴取得
    public func getHistory(index: Int) -> PageHistory? {
        return PageHistoryDataModel.s.getHistory(index: index)
    }

    /// 直近URL取得
    public func getMostForwardUrl(context: String) -> String? {
        return PageHistoryDataModel.s.getMostForwardUrl(context: context)
    }

    /// 過去ページ閲覧中フラグ取得
    public func getIsPastViewing(context: String) -> Bool? {
        return PageHistoryDataModel.s.isPastViewing(context: context)
    }

    /// 前回URL取得
    public func getBackUrl(context: String) -> String? {
        return PageHistoryDataModel.s.getBackUrl(context: context)
    }

    /// 次URL取得
    public func getForwardUrl(context: String) -> String? {
        return PageHistoryDataModel.s.getForwardUrl(context: context)
    }

    public func startLoading(context: String) {
        PageHistoryDataModel.s.startLoading(context: context)
    }

    public func endLoading(context: String) {
        PageHistoryDataModel.s.endLoading(context: context)
    }

    public func endRendering(context: String) {
        PageHistoryDataModel.s.endRendering(context: context)
        store()
    }

    public func updateProgress(object: CGFloat) {
        ProgressDataModel.s.updateProgress(progress: object)
    }

    /// 前WebViewに切り替え
    public func goBack() {
        PageHistoryDataModel.s.goBack()
    }

    /// 後WebViewに切り替え
    public func goNext() {
        PageHistoryDataModel.s.goNext()
    }

    /// update url in page history
    public func updateUrl(context: String, url: String, operation: PageHistory.Operation) {
        PageHistoryDataModel.s.updateUrl(context: context, url: url, operation: operation)
    }

    /// update title in page history
    public func updateTitle(context: String, title: String) {
        PageHistoryDataModel.s.updateTitle(context: context, title: title)
    }

    /// 閲覧、ページ履歴の永続化
    private func store() {
        DispatchQueue(label: ModelConst.APP.QUEUE).async {
            PageHistoryDataModel.s.store()
        }
    }

    public func initialize() {
        PageHistoryDataModel.s.initialize()
    }
}
