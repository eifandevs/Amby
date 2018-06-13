//
//  FrontLayerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

final class FrontLayerViewModel {
    deinit {
        log.debug("deinit called.")
    }

    func insertPageHistoryDataModel() {
        PageHistoryDataModel.s.append(url: nil)
    }

    func executeOperationDataModel(operation: UserOperation) {
        OperationDataModel.s.executeOperation(operation: operation, object: nil)
    }

    func registerFavoriteDataModel() {
        FavoriteDataModel.s.register()
    }

    func removePageHistoryDataModel() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
    }

    func beginEditingHeaderViewDataModel() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { in
            HeaderViewDataModel.s.beginEditing(forceEditFlg: true)
        }
    }

    func goForwardCommonHistoryDataModel() {
        CommonHistoryDataModel.s.goForward()
    }

    func goBackCommonHistoryDataModel() {
        CommonHistoryDataModel.s.goBack()
    }
}