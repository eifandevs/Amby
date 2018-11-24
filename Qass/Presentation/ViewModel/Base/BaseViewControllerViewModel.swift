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
    enum Action {
        case help(title: String, message: String)
        case menuOrder
        case passcode
        case passcodeConfirm
        case formReader(form: Form)
        case mailer
        case openSource
        case report
        case memo(memo: Memo)
        case notice(message: String, isSuccess: Bool)
    }

    let rx_action = PublishSubject<Action>()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    deinit {
        log.debug("deinit called.")
    }

    init() {
        setupRx()
    }

    private func setupRx() {
        // ヘルプ監視
        HelpUseCase.s.rx_helpUseCaseDidRequestPresentHelpScreen
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_helpUseCaseDidRequestPresentHelpScreen")
                guard let `self` = self, let object = object.element else { return }
                self.rx_action.onNext(Action.help(title: object.title, message: object.message))
                log.eventOut(chain: "rx_helpUseCaseDidRequestPresentHelpScreen")
            }
            .disposed(by: disposeBag)

        // メニュー順序表示監視
        MenuOrderUseCase.s.rx_menuOrderUseCaseDidRequestOpen
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_menuOrderUseCaseDidRequestOpen")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.menuOrder)
                log.eventOut(chain: "rx_menuOrderUseCaseDidRequestOpen")
            }
            .disposed(by: disposeBag)

        // パスコード表示監視
        PasscodeUseCase.s.rx_passcodeUseCaseDidRequestOpen
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_passcodeUseCaseDidRequestOpen")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.passcode)
                log.eventOut(chain: "rx_passcodeUseCaseDidRequestOpen")
            }
            .disposed(by: disposeBag)

        // パスコード確認表示監視
        PasscodeUseCase.s.rx_passcodeUseCaseDidRequestConfirm
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_passcodeUseCaseDidRequestConfirm")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.passcodeConfirm)
                log.eventOut(chain: "rx_passcodeUseCaseDidRequestConfirm")
            }
            .disposed(by: disposeBag)

        // フォーム閲覧表示監視
        FormUseCase.s.rx_formUseCaseDidRequestRead
            .subscribe { [weak self] form in
                log.eventIn(chain: "rx_formUseCaseDidRequestRead")
                guard let `self` = self, let form = form.element else { return }
                self.rx_action.onNext(Action.formReader(form: form))
                log.eventOut(chain: "rx_formUseCaseDidRequestRead")
            }
            .disposed(by: disposeBag)

        // メーラー表示監視
        ContactUseCase.s.rx_operationUseCaseDidRequestOpen
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_operationUseCaseDidRequestOpen")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.mailer)
                log.eventOut(chain: "rx_operationUseCaseDidRequestOpen")
            }
            .disposed(by: disposeBag)

        // オープンソース表示監視
        OpenSourceUseCase.s.rx_openSourceUseCaseDidRequestOpen
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_openSourceUseCaseDidRequestOpen")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.openSource)
                log.eventOut(chain: "rx_openSourceUseCaseDidRequestOpen")
            }
            .disposed(by: disposeBag)

        // レポート表示監視
        ReportUseCase.s.rx_reportUseCaseDidRequestOpen
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_reportUseCaseDidRequestOpen")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.report)
                log.eventOut(chain: "rx_reportUseCaseDidRequestOpen")
            }
            .disposed(by: disposeBag)

        // メモ表示監視
        MemoUseCase.s.rx_memoUseCaseDidRequestOpen
            .subscribe { [weak self] memo in
                log.eventIn(chain: "rx_memoUseCaseDidRequestOpen")
                guard let `self` = self, let memo = memo.element else { return }
                self.rx_action.onNext(Action.memo(memo: memo))
                log.eventOut(chain: "rx_memoUseCaseDidRequestOpen")
            }
            .disposed(by: disposeBag)

        // 通知監視
        NoticeUseCase.s.rx_noticeUseCaseDidInvoke
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_noticeUseCaseDidInvoke")
                guard let `self` = self, let object = object.element else { return }
                self.rx_action.onNext(Action.notice(message: object.message, isSuccess: object.isSuccess))
                log.eventOut(chain: "rx_noticeUseCaseDidInvoke")
            }
            .disposed(by: disposeBag)
    }

    func insertTab(url: String) {
        TabUseCase.s.insert(url: url)
    }
}
