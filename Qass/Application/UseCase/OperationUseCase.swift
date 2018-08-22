//
//  CircleMenuUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/22.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class OperationUseCase {

    static let s = OperationUseCase()

    /// ヒストリーバック通知用RX
    let rx_operationUseCaseDidGoBack = PublishSubject<()>()
    /// ヒストリーフォワード通知用RX
    let rx_operationUseCaseDidGoForward = PublishSubject<()>()

    private let disposeBag = DisposeBag()

    /// ヒストリーバック
    func historyBack() {
        rx_operationUseCaseDidGoBack.onNext(())
    }

    /// ヒストリーフォワード
    func historyForward() {
        rx_operationUseCaseDidGoForward.onNext(())
    }

    /// 現在のタブをクローズ
    func closeCurrentTab() {
        PageHistoryDataModel.s.remove(context: PageHistoryDataModel.s.currentContext)
    }

}
