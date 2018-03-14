//
//  OperationDataModel.swift
//  Qas
//
//  Created by temma on 2017/12/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

// ユーザー操作用モデル
final class OperationDataModel {
    /// オペレーション通知用RX
    let rx_operationDataModelDidChange = PublishSubject<(operation: UserOperation, object: Any?)>()
    
    static let s = OperationDataModel()
    var userOperation: UserOperation?
    private let center = NotificationCenter.default

    func executeOperation(operation: UserOperation, object: Any?) {
        userOperation = operation
        rx_operationDataModelDidChange.onNext((operation: operation, object: object))
    }
}
