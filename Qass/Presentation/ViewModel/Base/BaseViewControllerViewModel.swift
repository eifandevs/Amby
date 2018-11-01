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

    // パスコード設定表示通知用RX
    let rx_baseViewControllerViewModelDidPresentPasscode = PasscodeUseCase.s.rx_passcodeUseCaseDidRequestOpen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // フォーム閲覧通知用RX
    let rx_baseViewControllerViewModelDidPresentForm = FormUseCase.s.rx_formUseCaseDidRequestRead
        .flatMap { id -> Observable<Form> in
            if let form = FormUseCase.s.select(id: id).first {
                return Observable.just(form)
            } else {
                return Observable.empty()
            }
        }

    // メーラー起動通知用RX
    let rx_baseViewControllerViewModelDidPresentMail = ContactUseCase.s.rx_operationUseCaseDidRequestOpen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // オープンソース表示通知用RX
    let rx_baseViewControllerViewModelDidPresentOpenSource = OpenSourceUseCase.s.rx_openSourceUseCaseDidRequestOpen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // レポート表示通知用RX
    let rx_baseViewControllerViewModelDidPresentReport = ReportUseCase.s.rx_reportUseCaseDidRequestOpen
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    // メモ表示通知用RX
    let rx_baseViewControllerViewModelDidPresentMemo = MemoUseCase.s.rx_memoUseCaseDidRequestOpen
        .flatMap { memo -> Observable<Memo> in
            return Observable.just(memo)
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
                if let element = object.element {
                    NotificationManager.presentToastNotification(message: element.message, isSuccess: element.isSuccess)
                }
                log.eventOut(chain: "rx_noticeUseCaseDidInvoke")
            }
            .disposed(by: disposeBag)
    }

    func insertTab(url: String) {
        TabUseCase.s.insert(url: url)
    }
}
