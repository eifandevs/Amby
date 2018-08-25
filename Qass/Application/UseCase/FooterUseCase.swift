//
//  FooterUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// フッターユースケース
final class FooterUseCase {

    static let s = FooterUseCase()

    /// サムネイル追加通知用RX
    let rx_footerUseCaseDidAppendThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
        .flatMap { pageHistory -> Observable<PageHistory> in
            return Observable.just(pageHistory)
    }

    /// サムネイル追加用RX
    let rx_footerUseCaseDidInsertThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
        .flatMap { object -> Observable<(at: Int, pageHistory: PageHistory)> in
            return Observable.just((at: object.at, pageHistory: object.pageHistory))
    }

    /// サムネイル変更通知用RX
    let rx_footerUseCaseDidChangeThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
    }

    /// サムネイル削除用RX
    let rx_footerUseCaseDidRemoveThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
        .flatMap { object -> Observable<(deleteContext: String, currentContext: String?, deleteIndex: Int)> in
            // 実データの削除
            ThumbnailDataModel.s.delete(context: object.deleteContext)
            return Observable.just(object)
    }
}
