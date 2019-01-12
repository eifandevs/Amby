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

enum FooterViewModelAction {
    case update(indexPath: IndexPath?)
    case append(indexPath: IndexPath)
    case insert(at: Int, pageHistory: PageHistory)
    case change(context: String)
    case delete(deleteContext: String, currentContext: String?, deleteIndex: Int)
    case startLoading(context: String)
    case endLoading(context: String, title: String)
}

final class FooterViewModel {
    struct Row {
        var context: String
        var title: String
        var isFront: Bool
        var isLoading: Bool
        var thumbnail: UIImage?
    }

    /// アクション通知用RX
    let rx_action = PublishSubject<FooterViewModelAction>()

    var rows = TabUseCase.s.pageHistories.map { pageHistory -> FooterViewModel.Row in
        let isFront = pageHistory.context == TabUseCase.s.currentContext

        let thumbnail = ThumbnailUseCase.s.getThumbnail(context: pageHistory.context)
        let image = thumbnail?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))

        return Row(context: pageHistory.context, title: pageHistory.title, isFront: isFront, isLoading: pageHistory.isLoading, thumbnail: image)
    }

    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
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
        /// ローディング監視
        TabUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .append(pageHistory): self.append(pageHistory: pageHistory)
                case let .insert(at, pageHistory): self.rx_action.onNext(.insert(at: at, pageHistory: pageHistory))
                case .change: self.updateFrontBar()
                case let .delete(deleteContext, currentContext, deleteIndex): self.rx_action.onNext(.delete(deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex))
                case let .startLoading(context): self.startLoading(context: context)
                case let .endLoading(context, title): self.endLoading(context: context, title: title)
                case let .endRendering(context): self.endRendering(context: context)
                default: break
                }
            }
            .disposed(by: disposeBag)
    }

    private func append(pageHistory: PageHistory) {
        // まずはフロントバーを削除する
        deleteFrontBar()

        let thumbnail = ThumbnailUseCase.s.getThumbnail(context: pageHistory.context)
        let row = Row(context: pageHistory.context, title: pageHistory.title, isFront: true, isLoading: pageHistory.isLoading, thumbnail: thumbnail)
        rows.append(row)
        rx_action.onNext(.append(indexPath: IndexPath(row: rows.count - 1, section: 0)))
    }

    private func updateFrontBar() {
        for i in 0 ... rows.count - 1 {
            if rows[i].context == currentContext {
                rows[i].isFront = true
            } else {
                rows[i].isFront = false
            }
            rx_action.onNext(.update(indexPath: nil))
        }
    }

    private func deleteFrontBar() {
        for i in 0 ... rows.count - 1 where rows[i].isFront {
            rows[i].isFront = false
            rx_action.onNext(.update(indexPath: IndexPath(row: i, section: 0)))
            return
        }
    }

    private func startLoading(context: String) {
        if let index = rows.index(where: { $0.context == context }) {
            rows[index].isLoading = true
            rx_action.onNext(.update(indexPath: IndexPath(row: index, section: 0)))
        }
    }

    private func endLoading(context: String, title: String) {
        if let index = rows.index(where: { $0.context == context }) {
            rows[index].isLoading = false
            rows[index].title = title

            rx_action.onNext(.update(indexPath: IndexPath(row: index, section: 0)))
        }
    }

    private func endRendering(context: String) {
        if let index = rows.index(where: { $0.context == context }) {
            rows[index].thumbnail = getThumbnail(context: context)

            rx_action.onNext(.update(indexPath: IndexPath(row: index, section: 0)))
        }
    }

    func change(indexPath: IndexPath) {
        TabUseCase.s.change(context: rows[indexPath.row].context)
    }

    private func remove(context: String) {
        TabUseCase.s.remove(context: context)
    }

    private func getThumbnail(context: String) -> UIImage? {
        let thumbnail = ThumbnailUseCase.s.getThumbnail(context: context)
        return thumbnail?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))
    }
}
