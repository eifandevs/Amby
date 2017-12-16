//
//  HeaderFieldViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class HeaderFieldViewModel {
    func executeOperationDataModel(operation: UserOperation, object: String) {
        OperationDataModel.s.executeOperation(operation: operation, object: object)
    }
}
