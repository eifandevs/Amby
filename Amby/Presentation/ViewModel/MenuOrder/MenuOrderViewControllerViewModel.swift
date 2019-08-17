//
//  MenuOrderViewControllerViewModel.swift
//  Amby
//
//  Created by tenma on 2018/10/15.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

enum MenuOrderViewControllerViewModelAction {
    case reload
}

final class MenuOrderViewControllerViewModel {
    /// アクション通知用RX
    let rx_action = PublishSubject<MenuOrderViewControllerViewModelAction>()

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

    var menuOrder = GetSettingUseCase().menuOrder

    private var rows = UserOperation.allCases.map { Row(operation: $0) }

    /// usecase
    let getSettingUseCase = GetSettingUseCase()

    func getRow(index: Int) -> Row {
        return rows[index]
    }

    func getOrder(operation: UserOperation) -> MenuOrder {
        return MenuOrder(order: menuOrder.index(where: { $0 == operation }))
    }

    /// 並び替えの確定
    func changeOrder() {
        if menuOrder.count == AppConst.FRONT_LAYER.CIRCLEMENU_SECTION_NUM * AppConst.FRONT_LAYER.CIRCLEMENU_ROW_NUM {
            if menuOrder.index(where: { $0 == .menu }) == nil {
                log.warning("cannot change menu. menu is required")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.MENU_ORDER_CANNOT_SORT, isSuccess: false)
                }
            } else {
                log.debug("change menu order")
                getSettingUseCase.menuOrder = menuOrder
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.MENU_ORDER_SUCCESS, isSuccess: true)
                }
            }
        } else {
            log.warning("cannot change menu order. number error")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.MENU_ORDER_ERROR, isSuccess: false)
            }
        }
    }

    func sort(operation: UserOperation) {
        if let index = menuOrder.index(where: { $0 == operation }) {
            menuOrder.remove(at: index)
        } else {
            if menuOrder.count == AppConst.FRONT_LAYER.CIRCLEMENU_SECTION_NUM * AppConst.FRONT_LAYER.CIRCLEMENU_ROW_NUM {
                menuOrder.removeFirst()
            }
            menuOrder.append(operation)
        }

        rx_action.onNext(.reload)
    }

    /// 初期化
    func initialize() {
        getSettingUseCase.initializeMenuOrder()
        menuOrder = getSettingUseCase.menuOrder
        rx_action.onNext(.reload)
    }
}
