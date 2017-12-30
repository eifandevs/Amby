//
//  BaseViewControllerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

protocol BaseViewControllerViewModelDelegate: class {
    func baseViewControllerViewModelDelegateDidPresentHelp(subtitle: String, message: String)
}

class BaseViewControllerViewModel {

    var delegate: BaseViewControllerViewModelDelegate?

    init() {
        // ヘルプ画面の表示通知
        NotificationCenter.default.addObserver(forName: .operationDataModelDidChange, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            log.debug("[BaseViewController Event]: operationDataModelDidChange")
            let operation = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OPERATION] as! UserOperation
            if operation == .help {
                let object = (notification.object as! [String: Any])[AppConst.KEY_NOTIFICATION_OBJECT] as! [String: String]
                // ヘルプ画面を表示する
                let subtitle = object[AppConst.KEY_NOTIFICATION_SUBTITLE]!
                let message = object[AppConst.KEY_NOTIFICATION_MESSAGE]!
                self.delegate?.baseViewControllerViewModelDelegateDidPresentHelp(subtitle: subtitle, message: message)
            }
        }
    }

    func insertPageHistoryDataModel(url: String) {
        PageHistoryDataModel.s.insert(url: url)
    }
}
