//
//  MemoDataModel.swift
//  Model
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

final class MemoDataModel {
    static let s = MemoDataModel()

    /// db repository
    let repository = DBRepository()

    private init() {}

    /// insert forms
    func insert(memo: Memo) {
        repository.insert(data: [memo])
    }

    /// delete forms
    func delete(memo _: Memo) {
    }
}
