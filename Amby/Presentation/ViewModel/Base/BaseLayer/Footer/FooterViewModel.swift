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
    case update(indexPath: [IndexPath]?, animated: Bool)
    case append(indexPath: IndexPath)
    case insert(indexPath: IndexPath)
    case delete(indexPath: IndexPath)
    case startLoading(context: String)
    case endLoading(context: String, title: String)
}

final class FooterViewModel {
    struct Row {
        var context: String
        var title: String
        var isFront: Bool
        var isLoading: Bool
        var isDragging: Bool
        var thumbnail: UIImage?

        init(pageHistory: PageHistory) {
            let baseImage = ThumbnailUseCase.s.getThumbnail(context: pageHistory.context)
            let image = baseImage?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))

            context = pageHistory.context
            title = pageHistory.title
            isFront = pageHistory.context == TabUseCase.s.currentContext
            isLoading = pageHistory.isLoading
            isDragging = false
            thumbnail = image
        }
    }

    /// アクション通知用RX
    let rx_action = PublishSubject<FooterViewModelAction>()

    var rows = TabUseCase.s.pageHistories.map { Row(pageHistory: $0) }

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
                case let .append(before, after): self.append(before: before, after: after)
                case let .insert(before, after): self.insert(before: before, after: after)
                case let .change(before, after): self.change(before: before, after: after)
                case let .delete(isFront, deleteContext, currentContext, deleteIndex): self.delete(isFront: isFront, deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex)
                case let .startLoading(context): self.startLoading(context: context)
                case let .endLoading(context, title): self.endLoading(context: context, title: title)
                case let .endRendering(context): self.endRendering(context: context)
                default: break
                }
            }
            .disposed(by: disposeBag)
    }

    private func delete(isFront: Bool, deleteContext: String, currentContext: String?, deleteIndex _: Int) {
        for i in 0 ... rows.count - 1 where rows[i].context == deleteContext {
            rows.remove(at: i)
            rx_action.onNext(.delete(indexPath: IndexPath(row: i, section: 0)))
            return
        }
    }

    private func append(before _: (pageHistory: PageHistory, index: Int)?, after: (pageHistory: PageHistory, index: Int)) {
        let row = Row(pageHistory: after.pageHistory)
        rows.append(row)

        rx_action.onNext(.append(indexPath: IndexPath(row: after.index, section: 0)))
    }

    private func insert(before _: (pageHistory: PageHistory, index: Int), after: (pageHistory: PageHistory, index: Int)) {
        let row = Row(pageHistory: after.pageHistory)
        rows.insert(row, at: after.index)

        rx_action.onNext(.insert(indexPath: IndexPath(row: after.index, section: 0)))
    }

    private func change(before: (pageHistory: PageHistory, index: Int), after: (pageHistory: PageHistory, index: Int)) {
        rows[before.index].isFront = false
        rows[after.index].isFront = true

        rx_action.onNext(.update(indexPath: [before, after].map { IndexPath(row: $0.index, section: 0) }, animated: false))
    }

    private func startLoading(context: String) {
        if let index = rows.index(where: { $0.context == context }) {
            rows[index].isLoading = true
            rx_action.onNext(.update(indexPath: [IndexPath(row: index, section: 0)], animated: false))
        }
    }

    private func endLoading(context: String, title: String) {
        if let index = rows.index(where: { $0.context == context }) {
            rows[index].isLoading = false
            rows[index].title = title
        }
    }

    private func endRendering(context: String) {
        if let index = rows.index(where: { $0.context == context }) {
            rows[index].thumbnail = getThumbnail(context: context)

            rx_action.onNext(.update(indexPath: [IndexPath(row: index, section: 0)], animated: false))
        }
    }

    func swap(start: Int, end: Int) {
        rows.swapAt(start, end) // セルの更新がすぐ動くので、もう入れ替えておく
        TabUseCase.s.swap(start: start, end: end)
    }

    func startDragging() {
        for i in 0 ... rows.count - 1 {
            rows[i].isDragging = true
        }
    }

    func endDragging() {
        for i in 0 ... rows.count - 1 {
            rows[i].isDragging = false
        }
    }

    func updateFrontBar() {
        guard rows.count > 0 else { return }

        var updateIndexPath = [IndexPath]()

        for i in 0 ... rows.count - 1 {
            if rows[i].context == currentContext {
                if !rows[i].isFront {
                    rows[i].isFront = true
                    updateIndexPath.append(IndexPath(row: i, section: 0))
                }
            } else {
                if rows[i].isFront {
                    rows[i].isFront = false
                    updateIndexPath.append(IndexPath(row: i, section: 0))
                }
            }
        }

        if updateIndexPath.count > 0 {
            rx_action.onNext(.update(indexPath: updateIndexPath, animated: false))
        }
    }

    func change(indexPath: IndexPath) {
        TabUseCase.s.change(context: rows[indexPath.row].context)
    }

    private func getThumbnail(context: String) -> UIImage? {
        let thumbnail = ThumbnailUseCase.s.getThumbnail(context: context)
        return thumbnail?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))
    }
}
