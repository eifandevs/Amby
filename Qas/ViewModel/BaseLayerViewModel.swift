//
//  BaseLayerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

final class BaseLayerViewModel {
    func changeOperationDataModel(operation: UserOperation) {
        OperationDataModel.s.executeOperation(operation: operation, object: nil)
    }
    
    deinit {
        log.debug("deinit called.")
    }
}
