//
//  BaseViewControllerViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

final class BaseViewControllerViewModel {
    // ヘルプ表示通知用RX
    let rx_baseViewControllerViewModelDidPresentHelp = HelpUseCase.s.rx_helpUseCaseDidRequestPresentHelpScreen
        .flatMap { object -> Observable<(title: String, message: String)> in
            // ヘルプ画面を表示する
            return Observable.just((title: object.title, message: object.message))
        }

    // メニュー順序表示通知用RX
    let rx_baseViewControllerViewModelDidPresentMenuOrder = MenuOrderUseCase.s.rx_menuOrderUseCaseDidRequestOpen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // メーラー起動通知用RX
    let rx_baseViewControllerViewModelDidPresentMail = ContactUseCase.s.rx_operationUseCaseDidRequestPresentContactScreen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // オープンソース表示通知用RX
    let rx_baseViewControllerViewModelDidPresentOpenSource = OpenSourceUseCase.s.rx_openSourceUseCaseDidRequestPresentOpenSourceScreen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // レポート表示通知用RX
    let rx_baseViewControllerViewModelDidPresentReport = ReportUseCase.s.rx_reportUseCaseDidRequestPresentReportScreen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // レポート登録成功通知用RX
    let rx_baseViewControllerViewModelDidRegisterSuccess = ReportUseCase.s.rx_reportUseCaseDidRegisterSuccess
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // レポート登録失敗通知用RX
    let rx_baseViewControllerViewModelDidRegisterFailure = ReportUseCase.s.rx_reportUseCaseDidRegisterFailure
        .flatMap { error -> Observable<Error?> in
            return Observable.just(error)
        }

    /// Observable自動解放
    let disposeBag = DisposeBag()

    deinit {
        log.debug("deinit called.")
    }

    init() {
        setupRx()
    }

    private func setupRx() {
        NoticeUseCase.s.rx_noticeUseCaseDidInvoke
            .subscribe { object in
                log.eventIn(chain: "rx_noticeUseCaseDidInvoke")
                if let message = object.element {
                    NotificationManager.presentNotification(message: message)
                }

                log.eventOut(chain: "rx_noticeUseCaseDidInvoke")
            }
            .disposed(by: disposeBag)
    }

    func insertTab(url: String) {
        TabUseCase.s.insert(url: url)
    }
}
