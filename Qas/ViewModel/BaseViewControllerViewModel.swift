//
//  BaseViewControllerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol BaseViewControllerViewModelDelegate: class {
    func baseViewControllerViewModelDelegateDidPresentHelp(subtitle: String, message: String)
}

class BaseViewControllerViewModel {
    
    // ヘルプ表示通知用RX
    let rx_baseViewControllerViewModelDidPresentHelp = PublishSubject<(subtitle: String, message: String)>()

    /// Observable自動解放
    let disposeBag = DisposeBag()
    
    init() {
        // ヘルプ画面の表示通知
        NotificationCenter.default.rx.notification(.operationDataModelDidChange, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseViewControllerViewModel Event]: operationDataModelDidChange")
                if let notification = notification.element {
                    let operation = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OPERATION] as! UserOperation
                    if operation == .help {
                        let object = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OBJECT] as! [String: String]
                        // ヘルプ画面を表示する
                        let subtitle = object[AppConst.KEY_NOTIFICATION_SUBTITLE]!
                        let message = object[AppConst.KEY_NOTIFICATION_MESSAGE]!
                        self.rx_baseViewControllerViewModelDidPresentHelp.onNext((subtitle: subtitle, message: message))
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }
    
    func insertByEventPageHistoryDataModel(url: String) {
        PageHistoryDataModel.s.insert(url: url)
    }
}
