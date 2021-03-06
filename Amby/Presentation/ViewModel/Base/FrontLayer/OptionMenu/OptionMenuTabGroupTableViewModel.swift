//
//  OptionMenuTabGroupTableViewModel.swift
//  Amby
//
//  Created by tenma on 2019/02/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

enum OptionMenuTabGroupTableViewModelAction {
    case reload
}

final class OptionMenuTabGroupTableViewModel {
    // セル情報
    struct Row {
        let title: String
        let groupContext: String
        var isFront: Bool
        var isPrivate: Bool
    }

    /// アクション通知用RX
    let rx_action = PublishSubject<OptionMenuTabGroupTableViewModelAction>()

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    // セル
    private var rows: [Row] = TabHandlerUseCase.s.tabGroupList.groups.map({ Row(title: $0.title, groupContext: $0.groupContext, isFront: TabHandlerUseCase.s.tabGroupList.currentGroupContext == $0.groupContext, isPrivate: $0.isPrivate) })
    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    /// ユースケース
    let changeGroupUseCase = ChangeGroupUseCase()
    let deleteGroupUseCase = DeleteGroupUseCase()
    let addGroupUseCase = AddGroupUseCase()
    let invertPrivateModeUseCase = InvertPrivateModeUseCase()

    init() {
        setupRx()
    }

    func setupRx() {
        // リロード監視
        TabHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .appendGroup, .changeGroupTitle, .deleteGroup, .invertPrivateMode:
                    self.rows = TabHandlerUseCase.s.tabGroupList.groups.map({ Row(title: $0.title, groupContext: $0.groupContext, isFront: TabHandlerUseCase.s.tabGroupList.currentGroupContext == $0.groupContext, isPrivate: $0.isPrivate) })
                    self.rx_action.onNext(.reload)
                default: break
                }
            }
            .disposed(by: disposeBag)
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// セル削除
    func removeRow(indexPath: IndexPath) {
        // モデルから削除
        let row = getRow(indexPath: indexPath)
        deleteGroupUseCase.exe(groupContext: row.groupContext)
    }

    /// グループ作成
    func addGroup() {
        addGroupUseCase.exe()
    }

    /// セル押下
    func changeGroup(indexPath: IndexPath) {
        let row = getRow(indexPath: indexPath)
        changeGroupUseCase.exe(groupContext: row.groupContext)
    }

    /// グループ名変更
    func changeGroupTitle(indexPath: IndexPath) {
        let row = getRow(indexPath: indexPath)
        TabHandlerUseCase.s.presentGroupTitleEdit(groupContext: row.groupContext)
    }

    /// グループ名変更
    func invertPrivateMode(indexPath: IndexPath) {
        let row = getRow(indexPath: indexPath)
        invertPrivateModeUseCase.exe(groupContext: row.groupContext)
    }
}
