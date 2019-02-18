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
    }

    /// アクション通知用RX
    let rx_action = PublishSubject<OptionMenuTabGroupTableViewModelAction>()

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    // セル
    private var rows: [Row] {
        return TabUseCase.s.pageGroupList.groups.map({ Row(title: $0.title, groupContext: $0.groupContext, isFront: TabUseCase.s.pageGroupList.currentGroupContext == $0.groupContext) })
    }

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    init() {
        setupRx()
    }

    func setupRx() {
        // リロード監視
        TabUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .appendGroup = action else { return }
                self.rx_action.onNext(.reload)
            }
            .disposed(by: disposeBag)
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// グループ作成
    func addGroup() {
        TabUseCase.s.addGroup()
    }
}
