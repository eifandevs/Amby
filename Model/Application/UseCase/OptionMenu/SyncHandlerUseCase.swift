//
//  SyncHandlerUseCase.swift
//  Model
//
//  Created by iori tenma on 2019/06/16.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum SyncHandlerUseCaseAction {
    case present
}

/// レポートユースケース
public final class SyncHandlerUseCase {
    public static let s = SyncHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<SyncHandlerUseCaseAction>()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    /// 
    public func open() {
        rx_action.onNext(.present)
    }
}
