//
//  BaseViewControllerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class BaseViewControllerViewModel {
    // ヘルプ表示通知用RX
    let rx_baseViewControllerViewModelDidPresentHelp = HelpUseCase.s.rx_helpUseCaseDidRequestPresentHelpScreen
        .flatMap { object -> Observable<(title: String, message: String)> in
            // ヘルプ画面を表示する
            return Observable.just((title: object.title, message: object.message))
        }

    // メーラー起動通知用RX
    let rx_baseViewControllerViewModelDidPresentMail = ContactUseCase.s.rx_operationUseCaseDidRequestPresentContactScreen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    deinit {
        log.debug("deinit called.")
    }

    func insertByEventPageHistoryDataModel(url: String) {
        PageUseCase.s.insert(url: url)
    }
}
