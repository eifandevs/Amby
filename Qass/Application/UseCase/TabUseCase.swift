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

    /// タブの追加
    func add(url: String? = nil) {
        PageHistoryDataModel.s.append(url: url)
    }

    /// タブの挿入
    func insert(url: String) {
        PageHistoryDataModel.s.insert(url: url)
    }
}
