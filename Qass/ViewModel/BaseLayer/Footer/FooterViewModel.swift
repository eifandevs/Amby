//
//  FooterViewModel.swift
//  Eiger
//
//  Created by tenma on 2017/03/23.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class FooterViewModel {
    
    /// サムネイル追加通知用RX
    let rx_footerViewModelDidAppendThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
        .flatMap { pageHistory -> Observable<PageHistory> in
            return Observable.just(pageHistory)
        }

    /// サムネイル追加用RX
    let rx_footerViewModelDidInsertThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
        .flatMap { object -> Observable<(at: Int, pageHistory: PageHistory)> in
            return Observable.just((at: object.at, pageHistory: object.pageHistory))
        }

    /// サムネイル変更通知用RX
    let rx_footerViewModelDidChangeThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
        }

    /// サムネイル削除用RX
    let rx_footerViewModelDidRemoveThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
        .flatMap { object -> Observable<(deleteContext: String, currentContext: String?, deleteIndex: Int)> in
            // 実データの削除
            ThumbnailDataModel.s.delete(context: object.deleteContext)
            return Observable.just(object)
        }

    /// ローディング開始通知用RX
    let rx_footerViewModelDidStartLoading = PageHistoryDataModel.s.rx_pageHistoryDataModelDidStartLoading
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
        }

    /// ローディング終了通知用RX
    let rx_footerViewModelDidEndLoading = PageHistoryDataModel.s.rx_pageHistoryDataModelDidEndRendering
        .flatMap { context -> Observable<(context: String, title: String)> in
            if let pageHistory = PageHistoryDataModel.s.getHistory(context: context) {
                return Observable.just((context: context, title: pageHistory.title))
            } else {
                return Observable.empty()
            }
        }

    /// 現在位置
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

    /// 通知センター
    let center = NotificationCenter.default

    /// Observable自動解放
    let disposeBag = DisposeBag()

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public Method

    func changePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.change(context: context)
    }

    func removePageHistoryDataModel(context: String) {
        PageHistoryDataModel.s.remove(context: context)
    }
}
