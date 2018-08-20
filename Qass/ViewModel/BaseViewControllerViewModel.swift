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
                if let object = object.object as? [String: String] {
                    let subtitle = object[AppConst.KEY.NOTIFICATION_SUBTITLE]!
                    let message = object[AppConst.KEY.NOTIFICATION_MESSAGE]!
                    return Observable.just((subtitle: subtitle, message: message))
                }

                return Observable.empty()
            } else {
                return Observable.empty()
            }
        }

    // メーラー起動通知用RX
    let rx_baseViewControllerViewModelDidPresentMail = OperationDataModel.s.rx_operationDataModelDidChange
        .flatMap { object -> Observable<()> in
            if object.operation == .contact {
                return Observable.just(())
            }
            return Observable.empty()
        }

    deinit {
        log.debug("deinit called.")
    }

    func insertByEventPageHistoryDataModel(url: String) {
        PageHistoryDataModel.s.insert(url: url)
    }
}
