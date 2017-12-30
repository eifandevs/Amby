//
//  OperationDataModel.swift
//  Qas
//
//  Created by temma on 2017/12/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

// ユーザー操作用モデル
final class OperationDataModel {
    static let s = OperationDataModel()
    var userOperation: UserOperation?
    private let center = NotificationCenter.default

    func executeOperation(operation: UserOperation, object: Any?) {
        userOperation = operation
        center.post(name: .operationDataModelDidChange, object: [AppConst.KEY_NOTIFICATION_OPERATION: operation, AppConst.KEY_NOTIFICATION_OBJECT: object])
    }
}
