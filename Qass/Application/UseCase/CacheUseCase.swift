//
//  CacheUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/27.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// キャッシュユースケース
final class CacheUseCase {

    static let s = CacheUseCase()

    private init() {}

    func deleteCookies() {
        CacheHelper.deleteCookies()
    }

    /// キャッシュ削除
    func deleteCaches() {
        CacheHelper.deleteCaches()
    }
}
