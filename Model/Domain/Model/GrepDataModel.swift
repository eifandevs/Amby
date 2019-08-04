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
}

final class GrepDataModel: GrepDataModelProtocol {
    var grepResultCount: (current: Int, total: Int) = (0, 0)
    static let s = GrepDataModel()

    private init() {}
}
