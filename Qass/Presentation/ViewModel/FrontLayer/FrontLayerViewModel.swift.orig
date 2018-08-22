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

    func executeOperationDataModel(operation: UserOperation, object: Any? = nil) {
        OperationDataModel.s.executeOperation(operation: operation, object: object)
    }

    func registerFavoriteDataModel() {
        FavoriteDataModel.s.update()
    }

    func removePageHistoryDataModel() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
    }

    func copyPageHistoryDataModel() {
        PageHistoryDataModel.s.copy()
    }

    func beginEditingHeaderViewDataModel() {
        HeaderViewDataModel.s.beginEditing(forceEditFlg: true)
    }

    func beginGrepingHeaderViewDataModel() {
        HeaderViewDataModel.s.beginGreping()
    }

    func goForwardCommonHistoryDataModel() {
        CommonHistoryDataModel.s.goForward()
    }

    func goBackCommonHistoryDataModel() {
        CommonHistoryDataModel.s.goBack()
    }
}
