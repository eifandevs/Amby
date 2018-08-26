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

/// タブユースケース
final class TabUseCase {

    static let s = TabUseCase()

    /// ページインサート通知用RX
    let rx_tabUseCaseDidInsert = PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
        .flatMap { object -> Observable<Int> in
            return Observable.just(object.at)
    }

    /// ページリロード通知用RX
    let rx_tabUseCaseDidReload = PageHistoryDataModel.s.rx_pageHistoryDataModelDidReload.flatMap { _ in Observable.just(()) }
    /// ページ追加通知用RX
    let rx_tabUseCaseDidAppend = PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend.flatMap { _ in Observable.just(()) }
    /// ページ変更通知用RX
    let rx_tabUseCaseDidChange = PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange.flatMap { _ in Observable.just(()) }
    /// ページ削除通知用RX
    let rx_tabUseCaseDidRemove = PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
        .flatMap { object -> Observable<(deleteContext: String, currentContext: String?, deleteIndex: Int)> in
            return Observable.just(object)
    }

    /// ローディング開始通知用RX
    let rx_tabUseCaseDidStartLoading = PageHistoryDataModel.s.rx_pageHistoryDataModelDidStartLoading
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
    }

    /// ローディング終了通知用RX
    let rx_tabUseCaseDidEndLoading = PageHistoryDataModel.s.rx_pageHistoryDataModelDidEndRendering
        .flatMap { context -> Observable<(context: String, title: String)> in
            if let isLoading = PageHistoryDataModel.s.getIsLoading(context: context) {
                if !isLoading {
                    // When loading is completed and loading has started while saving thumbnails, skip
                    if let pageHistory = PageHistoryDataModel.s.getHistory(context: context) {
                        return Observable.just((context: context, title: pageHistory.title))
                    } else {
                        return Observable.empty()
                    }
                } else {
                    log.warning("start loading while saving thumbnails.")
                }
            }

            return Observable.empty()
    }

    var currentUrl: String? {
        return PageHistoryDataModel.s.currentHistory?.url
    }

    var pageHistories: [PageHistory] {
        return PageHistoryDataModel.s.histories
    }

    var currentHistory: PageHistory? {
        return PageHistoryDataModel.s.currentHistory
    }

    var currentContext: String {
        return PageHistoryDataModel.s.currentContext
    }

    var currentLocation: Int? {
        return PageHistoryDataModel.s.currentLocation
    }

    var currentPageCount: Int {
        return PageHistoryDataModel.s.histories.count
    }

    private init() {}

    /// 現在のタブをクローズ
    func close() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
    }

    /// 現在のタブをコピー
    func copy() {
        PageHistoryDataModel.s.copy()
    }

    /// 現在のタブを削除
    func remove() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
    }

    /// 特定のタブを削除
    func remove(context: String) {
        PageHistoryDataModel.s.remove(context: context)
    }

    /// タブ変更
    func change(context: String) {
        PageHistoryDataModel.s.change(context: context)
    }

    /// タブの追加
    func add(url: String? = nil) {
        PageHistoryDataModel.s.append(url: url)
    }

    /// タブの挿入
    func insert(url: String? = nil) {
        PageHistoryDataModel.s.insert(url: url)
    }

    /// ページインデックス取得
    func getIndex(context: String) -> Int? {
        return PageHistoryDataModel.s.getIndex(context: context)
    }

    /// 履歴取得
    func getHistory(index: Int) -> PageHistory? {
        return PageHistoryDataModel.s.getHistory(index: index)
    }

    /// 直近URL取得
    func getMostForwardUrl(context: String) -> String? {
        return PageHistoryDataModel.s.getMostForwardUrl(context: context)
    }

    /// 過去ページ閲覧中フラグ取得
    func getIsPastViewing(context: String) -> Bool? {
        return PageHistoryDataModel.s.isPastViewing(context: context)
    }

    /// 前回URL取得
    func getBackUrl(context: String) -> String? {
        return PageHistoryDataModel.s.getBackUrl(context: context)
    }

    /// 次URL取得
    func getForwardUrl(context: String) -> String? {
        return PageHistoryDataModel.s.getForwardUrl(context: context)
    }

    func startLoading(context: String) {
        PageHistoryDataModel.s.startLoading(context: context)
    }

    func endLoading(context: String) {
        PageHistoryDataModel.s.endLoading(context: context)
    }

    func endRendering(context: String) {
        PageHistoryDataModel.s.endRendering(context: context)
    }

    func updateProgress(object: CGFloat) {
        ProgressDataModel.s.updateProgress(progress: object)
    }

    /// 前WebViewに切り替え
    func goBack() {
        PageHistoryDataModel.s.goBack()
    }

    /// 後WebViewに切り替え
    func goNext() {
        PageHistoryDataModel.s.goNext()
    }

    /// update url in page history
    func updateUrl(context: String, url: String, operation: PageHistory.Operation) {
        PageHistoryDataModel.s.updateUrl(context: context, url: url, operation: operation)
    }

    /// update title in page history
    func updateTitle(context: String, title: String) {
        PageHistoryDataModel.s.updateTitle(context: context, title: title)
    }

    /// 閲覧、ページ履歴の永続化
    func store() {
        PageHistoryDataModel.s.store()
    }
}
