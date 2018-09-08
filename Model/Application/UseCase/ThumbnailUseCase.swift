//
//  ThumbnailUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/25.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// フッターユースケース
public final class ThumbnailUseCase {
    public static let s = ThumbnailUseCase()

    /// サムネイル追加通知用RX
    public let rx_thumbnailUseCaseDidAppendThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidAppend
        .flatMap { pageHistory -> Observable<PageHistory> in
            return Observable.just(pageHistory)
        }

    /// サムネイル追加用RX
    public let rx_thumbnailUseCaseDidInsertThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidInsert
        .flatMap { object -> Observable<(at: Int, pageHistory: PageHistory)> in
            return Observable.just((at: object.at, pageHistory: object.pageHistory))
        }

    /// サムネイル変更通知用RX
    public let rx_thumbnailUseCaseDidChangeThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidChange
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
        }

    /// サムネイル削除用RX
    public let rx_thumbnailUseCaseDidRemoveThumbnail = PageHistoryDataModel.s.rx_pageHistoryDataModelDidRemove
        .flatMap { object -> Observable<(deleteContext: String, currentContext: String?, deleteIndex: Int)> in
            // 実データの削除
            ThumbnailDataModel.s.delete(context: object.deleteContext)
            return Observable.just(object)
        }

    private init() {}

    public func getCapture(context: String) -> UIImage? {
        return ThumbnailDataModel.s.getCapture(context: context)
    }

    /// create thumbnail folder
    public func createFolder(context: String) {
        ThumbnailDataModel.s.create(context: context)
    }

    /// write thumbnail data
    public func write(context: String, data: Data) {
        ThumbnailDataModel.s.write(context: context, data: data)
    }

    public func delete() {
        ThumbnailDataModel.s.delete()
    }

    /// サムネイルの削除
    public func delete(context: String) {
        ThumbnailDataModel.s.delete(context: context)
    }

    public func getThumbnail(context: String) -> UIImage? {
        return ThumbnailDataModel.s.getThumbnail(context: context)
    }
}
