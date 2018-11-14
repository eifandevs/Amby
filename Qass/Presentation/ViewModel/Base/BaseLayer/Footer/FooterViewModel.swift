//
//  FooterViewModel.swift
//  Eiger
//
//  Created by tenma on 2017/03/23.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

final class FooterViewModel {
    struct Row {
        var context: String?
        var title: String
        var isFront: Bool
        var isLoading: Bool
        var image: UIImage?
    }

    var rows = TabUseCase.s.pageHistories.map { pageHistory -> FooterViewModel.Row in
        let isFront = pageHistory.context == TabUseCase.s.currentContext

        let thumbnail = ThumbnailUseCase.s.getThumbnail(context: pageHistory.context)
        let image = thumbnail?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))

        return Row(context: pageHistory.context, title: pageHistory.title, isFront: isFront, isLoading: pageHistory.isLoading, image: image)
    }

    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// 更新通知用RX
    let rx_footerViewModelWillUpdate = PublishSubject<IndexPath?>()

    /// サムネイル挿入用RX
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
            return Observable.just(object)
        }

    /// ローディング開始通知用RX
    let rx_footerViewModelDidStartLoading = TabUseCase.s.rx_tabUseCaseDidStartLoading
        .flatMap { context -> Observable<String> in
            return Observable.just(context)
        }

    /// ローディング終了通知用RX
    let rx_footerViewModelDidEndLoading = TabUseCase.s.rx_tabUseCaseDidEndLoading
        .flatMap { context -> Observable<(context: String, title: String)> in
            return Observable.just(context)
        }

    /// 現在位置
    private var pageHistories: [PageHistory] {
        return TabUseCase.s.pageHistories
    }

    private var currentHistory: PageHistory? {
        return TabUseCase.s.currentHistory
    }

    private var currentContext: String {
        return TabUseCase.s.currentContext
    }

    private var currentLocation: Int? {
        return TabUseCase.s.currentLocation
    }

    /// 通知センター
    let center = NotificationCenter.default

    /// Observable自動解放
    let disposeBag = DisposeBag()

    init() {
        setupRx()
    }

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Private Method

    private func setupRx() {
        /// サムネイル追加監視
        ThumbnailUseCase.s.rx_thumbnailUseCaseDidAppendThumbnail
            .subscribe { [weak self] pageHistory in
                log.eventIn(chain: "rx_thumbnailUseCaseDidAppendThumbnail")
                guard let `self` = self else { return }
                if let pageHistory = pageHistory.element {
                    let isFront = pageHistory.context == TabUseCase.s.currentContext

                    let thumbnail = ThumbnailUseCase.s.getThumbnail(context: pageHistory.context)
                    let image = thumbnail?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))

                    let row = Row(context: pageHistory.context, title: pageHistory.title, isFront: isFront, isLoading: pageHistory.isLoading, image: image)
                    self.rows.append(row)
                    self.rx_footerViewModelWillUpdate.onNext(nil)
                }
                log.eventOut(chain: "rx_thumbnailUseCaseDidAppendThumbnail")
            }
            .disposed(by: disposeBag)
    }

    private func change(context: String) {
        TabUseCase.s.change(context: context)
    }

    private func remove(context: String) {
        TabUseCase.s.remove(context: context)
    }

    private func getThumbnail(context: String) -> UIImage? {
        let thumbnail = ThumbnailUseCase.s.getThumbnail(context: context)
        return thumbnail?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))
    }
}
