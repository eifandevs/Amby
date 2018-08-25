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
final class SourceCodeUseCase {

    static let s = SourceCodeUseCase()

    /// ロードリクエスト通知用RX
    let rx_sourceCodeUseCaseDidRequestLoad = PublishSubject<String>()

    private init() {}

    /// ソースコードページ表示
    func load() {
        rx_sourceCodeUseCaseDidRequestLoad.onNext(HttpConst.URL.SOURCE_URL)
    }
}
