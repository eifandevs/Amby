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

enum BaseViewControllerViewModelAction {
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

final class BaseViewControllerViewModel {

    let rx_action = PublishSubject<BaseViewControllerViewModelAction>()

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
        HelpUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .present(title, message) = action else { return }
                self.rx_action.onNext(.help(title: title, message: message))
            }
            .disposed(by: disposeBag)
        
        // 表示順序監視
        MenuOrderUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.menuOrder)
            }
            .disposed(by: disposeBag)

        
        // パスコード監視
        PasscodeUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                
                if case .present = action {
                    self.rx_action.onNext(.passcode)
                } else if case .confirm = action {
                    self.rx_action.onNext(.passcodeConfirm)
                }
            }
            .disposed(by: disposeBag)

        // フォーム閲覧表示監視
        FormUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .read(form) = action else { return }
                self.rx_action.onNext(.formReader(form: form))
            }
            .disposed(by: disposeBag)
        
        // メーラー表示監視
        ContactUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.mailer)
            }
            .disposed(by: disposeBag)

        // オープンソース表示監視
        OpenSourceUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.openSource)
            }
            .disposed(by: disposeBag)

        // レポート表示監視
        ReportUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.report)
            }
            .disposed(by: disposeBag)
        
        // メモ表示監視
        MemoUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .present(memo) = action else { return }
                self.rx_action.onNext(.memo(memo: memo))
            }
            .disposed(by: disposeBag)
        
        // 通知監視
        NoticeUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .present(message, isSuccess) = action else { return }
                self.rx_action.onNext(.notice(message: message, isSuccess: isSuccess))
            }
            .disposed(by: disposeBag)
    }

    func insertTab(url: String) {
        TabUseCase.s.insert(url: url)
    }
}
