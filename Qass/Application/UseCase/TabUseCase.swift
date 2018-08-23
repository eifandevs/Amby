//
//  TabUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// タブユースケース
final class TabUseCase {

    static let s = TabUseCase()

    /// 現在のタブをクローズ
    func close() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
    }

    /// 現在のタブをコピー
    func copy() {
        PageHistoryDataModel.s.copy()
    }

    /// 現在のタブを削除
    func remove() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
    }

    /// タブの追加
    func add(url: String? = nil) {
        PageHistoryDataModel.s.append(url: url)
    }

    /// タブの挿入
    func insert(url: String) {
        PageHistoryDataModel.s.insert(url: url)
    }
}
