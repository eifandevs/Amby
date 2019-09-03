//
//  GrepDataModel.swift
//  Model
//
//  Created by iori tenma on 2019/08/04.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Moya
import RxCocoa
import RxSwift

protocol GrepDataModelProtocol {
    var grepResultCount: (current: Int, total: Int) { get set }
    func finish(hitNum: Int)
    func previous() -> Bool
    func next()
}

final class GrepDataModel: GrepDataModelProtocol {
    var grepResultCount: (current: Int, total: Int) = (0, 0)
    static let s = GrepDataModel()

    private init() {}

    /// グレップ完了
    func finish(hitNum: Int) {
        grepResultCount = (0, hitNum)
    }

    /// 前に移動
    public func previous() -> Bool {
        guard grepResultCount.current > 0 else { return false }
        grepResultCount.current -= 1
        return true
    }

    /// 次に移動
    public func next() {
        let index = grepResultCount.current == grepResultCount.total ? 0 : grepResultCount.current + 1
        grepResultCount.current = index
    }
}
