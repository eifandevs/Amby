//
//  MenuOrderViewControllerViewModel.swift
//  Qass
//
//  Created by tenma on 2018/10/15.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

final class MenuOrderViewControllerViewModel {
    /// ページリロード通知用RX
    let rx_menuOrderViewControllerViewModelDidReload = PublishSubject<()>()

    // セル情報
    struct Row {
        let operation: UserOperation
    }

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_MENU_ORDER_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    private var menuOrder: [UserOperation] {
        return SettingUseCase.s.menuOrder
    }

    private var rows = UserOperation.enumerate().map { Row(operation: $0.element) }

    func getRow(index: Int) -> Row {
        return rows[index]
    }

    func getOrder(operation: UserOperation) -> Int? {
        return menuOrder.index(where: { $0 == operation })
    }

    func changeOrder(operation _: UserOperation) {
        // TODO: メニュー順序変更
        SettingUseCase.s.menuOrder = [.add, .autoScroll, .autoScroll, .close, .copy, .form, .grep, .closeAll, .historyBack, .historyForward, .menu, .urlCopy]

        rx_menuOrderViewControllerViewModelDidReload.onNext(())
    }

    /// 初期化
    func initialize() {
        SettingUseCase.s.initializeMenuOrder()
        rx_menuOrderViewControllerViewModelDidReload.onNext(())
    }
}
