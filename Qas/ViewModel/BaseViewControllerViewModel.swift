//
//  BaseViewControllerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class BaseViewControllerViewModel {
    func insertPageHistoryDataModel(url: String) {
        PageHistoryDataModel.s.insert(url: url)
    }
}
