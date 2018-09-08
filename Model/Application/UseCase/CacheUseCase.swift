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
public final class CacheUseCase {
    public static let s = CacheUseCase()

    private init() {}

    public func deleteCookies() {
        CacheHelper.deleteCookies()
    }

    /// キャッシュ削除
    public func deleteCaches() {
        CacheHelper.deleteCaches()
    }
}
