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
    let rx_footerViewModelDidAppendThumbnail = ThumbnailUseCase.s.rx_thumbnailUseCaseDidAppendThumbnail
        .flatMap { pageHistory -> Observable<PageHistory> in
            return Observable.just(pageHistory)
        }

    /// サムネイル追加用RX
    let rx_footerViewModelDidInsertThumbnail = ThumbnailUseCase.s.rx_thumbnailUseCaseDidInsertThumbnail
        .flatMap { object -> Observable<(at: Int, pageHistory: PageHistory)> in
            return Observable.just((at: object.at, pageHistory: object.pageHistory))
        }

    /// サムネイル変更通知用RX
    let rx_footerViewModelDidChangeThumbnail = ThumbnailUseCase.s.rx_thumbnailUseCaseDidChangeThumbnail
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
        }

    /// サムネイル削除用RX
    let rx_footerViewModelDidRemoveThumbnail = ThumbnailUseCase.s.rx_thumbnailUseCaseDidRemoveThumbnail
        .flatMap { object -> Observable<(deleteContext: String, currentContext: String?, deleteIndex: Int)> in
            // 実データの削除
            ThumbnailDataModel.s.delete(context: object.deleteContext)
            return Observable.just(object)
        }

    /// ローディング開始通知用RX
    let rx_footerViewModelDidStartLoading = PageUseCase.s.rx_pageUseCaseDidStartLoading
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
        }

    /// ローディング終了通知用RX
    let rx_footerViewModelDidEndLoading = PageUseCase.s.rx_pageUseCaseDidEndLoading
        .flatMap { context -> Observable<(context: String, title: String)> in
            return Observable.just(context)
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
