//
//  SourceCodeUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ソースコードユースケース
public final class SourceCodeUseCase {
    public static let s = SourceCodeUseCase()

    /// ロードリクエスト通知用RX
    public let rx_sourceCodeUseCaseDidRequestLoad = PublishSubject<String>()

    private init() {}

    /// ソースコードページ表示
    public func open() {
        rx_sourceCodeUseCaseDidRequestLoad.onNext(ModelConst.URL.SOURCE_URL)
    }
}
