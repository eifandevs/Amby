//
//  ReportViewControllerViewModel.swift
//  Qass
//
//  Created by tenma on 2018/10/07.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class ReportViewControllerViewModel {
    /// 一覧表示
    func openList() {
        ReportUseCase.s.openList()
    }
}
