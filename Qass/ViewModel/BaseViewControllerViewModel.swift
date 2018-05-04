//
//  BaseViewControllerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class BaseViewControllerViewModel {
    // ヘルプ表示通知用RX
    let rx_baseViewControllerViewModelDidPresentHelp = OperationDataModel.s.rx_operationDataModelDidChange
        .flatMap { object -> Observable<(subtitle: String, message: String)> in
            if object.operation == .help {
                // ヘルプ画面を表示する
                let object = object.object as! [String: String]
                let subtitle = object[AppConst.KEY_NOTIFICATION_SUBTITLE]!
                let message = object[AppConst.KEY_NOTIFICATION_MESSAGE]!
                return Observable.just((subtitle: subtitle, message: message))
            } else {
                return Observable.empty()
            }
        }

    deinit {
        log.debug("deinit called.")
    }

    func insertByEventPageHistoryDataModel(url: String) {
        PageHistoryDataModel.s.insert(url: url)
    }
}
