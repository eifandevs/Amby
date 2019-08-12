//
//  FooterViewModel.swift
//  Eiger
//
//  Created by tenma on 2017/03/23.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Entity
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
    struct Row: Equatable {
        var context: String
        var title: String
        var isFront: Bool
        var isLoading: Bool
        var isDragging: Bool
        var thumbnail: UIImage?

        init(tab: Tab) {
            let baseImage = GetThumbnailUseCase().exe(context: tab.context)
            let image = baseImage?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))

            context = tab.context
            title = tab.title
            isFront = tab.context == TabHandlerUseCase.s.currentContext
            isLoading = tab.isLoading
            isDragging = false
            thumbnail = image
        }

        static func == (lhs: Row, rhs: Row) -> Bool {
            return lhs.context == rhs.context
        }
    }

    /// アクション通知用RX
    let rx_action = PublishSubject<FooterViewModelAction>()

    var rows = [Row]()

    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// 現在位置
    private var tabs: [Tab] {
        return TabHandlerUseCase.s.tabs
    }

    private var currentTab: Tab? {
        return TabHandlerUseCase.s.currentTab
    }

    private var currentContext: String {
        return TabHandlerUseCase.s.currentContext
    }

    private var currentLocation: Int? {
        return TabHandlerUseCase.s.currentLocation
    }

    /// ユースケース
    private let swapTabUseCase = SwapTabUseCase()
    private let changeTabUseCase = ChangeTabUseCase()
    private let getThumbnailUseCase = GetThumbnailUseCase()

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    init() {
        setupRx()
    }

    deinit {
        log.debug("deinit called.")
    }

    // MARK: Private Method

    private func setupRx() {
        /// ローディング監視
        TabHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .append(before, after): self.append(before: before, after: after)
                case let .insert(before, after): self.insert(before: before, after: after)
                case let .change(before, after): self.change(before: before, after: after)
                case let .delete(isFront, deleteContext, currentContext, deleteIndex): self.delete(isFront: isFront, deleteContext: deleteContext, currentContext: currentContext, deleteIndex: deleteIndex)
                case let .startLoading(context): self.startLoading(context: context)
                case let .endLoading(context, title): self.endLoading(context: context, title: title)
                case .rebuildThumbnail: self.rebuild()
                case let .endRendering(context): self.endRendering(context: context)
                default: break
                }
            }
            .disposed(by: disposeBag)
    }

    private func rebuild() {
        // 再構築
        rows.removeAll()
        rows = TabHandlerUseCase.s.tabs.map { Row(tab: $0) }
        rx_action.onNext(.update(indexPath: nil, animated: true))
    }

    private func delete(isFront: Bool, deleteContext: String, currentContext: String?, deleteIndex _: Int) {
        for i in 0 ... rows.count - 1 where rows[i].context == deleteContext {
            rows.remove(at: i)
            rx_action.onNext(.delete(indexPath: IndexPath(row: i, section: 0)))
            return
        }
    }

    private func append(before _: (tab: Tab, index: Int)?, after: (tab: Tab, index: Int)) {
        let row = Row(tab: after.tab)
        rows.append(row)

        rx_action.onNext(.append(indexPath: IndexPath(row: after.index, section: 0)))
    }

    private func insert(before _: (tab: Tab, index: Int), after: (tab: Tab, index: Int)) {
        let row = Row(tab: after.tab)
        rows.insert(row, at: after.index)

        rx_action.onNext(.insert(indexPath: IndexPath(row: after.index, section: 0)))
    }

    private func change(before: (tab: Tab, index: Int), after: (tab: Tab, index: Int)) {
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
        rows = rows.move(from: start, to: end) // セルの更新がすぐ動くので、もう入れ替えておく
        swapTabUseCase.exe(start: start, end: end)
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
        changeTabUseCase.exe(context: rows[indexPath.row].context)
    }

    private func getThumbnail(context: String) -> UIImage? {
        let thumbnail = getThumbnailUseCase.exe(context: context)
        return thumbnail?.crop(w: Int(AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2), h: Int((AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * 2) * AppConst.DEVICE.ASPECT_RATE))
    }
}
