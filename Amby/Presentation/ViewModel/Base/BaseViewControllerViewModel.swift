//
//  BaseViewControllerViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Entity
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
    case sync
    case memo(memo: Memo)
    case notice(message: String, isSuccess: Bool)
    case tabGroupTitle(groupContext: String)
    case loginRequest(uid: String)
}

final class BaseViewControllerViewModel {
    let rx_action = PublishSubject<BaseViewControllerViewModelAction>()

    /// ユースケース
    let changeGroupTitleUseCase = ChangeGroupTitleUseCase()
    let insertTabUseCase = InsertTabUseCase()
    let initializeTabUseCase = InitializeTabUseCase()
    let loginUseCase = LoginUseCase()
    let fetchFavoriteUseCase = FetchFavoriteUseCase()
    let fetchMemoUseCase = FetchMemoUseCase()
    let fetchTabUseCase = FetchTabUseCase()
    let fetchFormUseCase = FetchFormUseCase()
    let postFavoriteUC = PostFavoriteUseCase()
    let postFormUC = PostFormUseCase()
    let postMemoUC = PostMemoUseCase()
    let postTabUC = PostTabUseCase()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    deinit {
        log.debug("deinit called.")
    }

    init() {
        setupRx()
    }

    private func setupRx() {
        // タブグループタイトル編集ダイアログ
        TabHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .presentGroupTitleEdit(groupContext) = action else { return }
                self.rx_action.onNext(.tabGroupTitle(groupContext: groupContext))
            }
            .disposed(by: disposeBag)

        // ヘルプ監視
        LoginHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .begin(uid) = action else { return }
                self.rx_action.onNext(.loginRequest(uid: uid))
            }
            .disposed(by: disposeBag)

        // ヘルプ監視
        HelpHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .present(title, message) = action else { return }
                self.rx_action.onNext(.help(title: title, message: message))
            }
            .disposed(by: disposeBag)

        // 表示順序監視
        MenuOrderHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.menuOrder)
            }
            .disposed(by: disposeBag)

        // パスコード監視
        LocalAuthenticationHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }

                if case .present = action {
                    self.rx_action.onNext(.passcode)
                } else if case .confirm = action {
                    self.rx_action.onNext(.passcodeConfirm)
                }
            }
            .disposed(by: disposeBag)

        // 同期監視
        SyncHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.sync)
            }
            .disposed(by: disposeBag)

        // フォーム閲覧表示監視
        FormHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .read(form) = action else { return }
                self.rx_action.onNext(.formReader(form: form))
            }
            .disposed(by: disposeBag)

        // メーラー表示監視
        ContactHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.mailer)
            }
            .disposed(by: disposeBag)

        // オープンソース表示監視
        OpenSourceHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.openSource)
            }
            .disposed(by: disposeBag)

        // レポート表示監視
        ReportHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .present = action else { return }
                self.rx_action.onNext(.report)
            }
            .disposed(by: disposeBag)

        // メモ表示監視
        MemoHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .present(memo) = action else { return }
                self.rx_action.onNext(.memo(memo: memo))
            }
            .disposed(by: disposeBag)

        // 通知監視
        NoticeHandlerUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .present(message, isSuccess) = action else { return }
                self.rx_action.onNext(.notice(message: message, isSuccess: isSuccess))
            }
            .disposed(by: disposeBag)
    }

    func initializeTab() {
        initializeTabUseCase.exe()
    }

    func insertTab(url: String) {
        insertTabUseCase.exe(url: url)
    }

    func changeGroupTitle(groupContext: String, title: String) {
        changeGroupTitleUseCase.exe(groupContext: groupContext, title: title)
    }

    func login(uid: String) -> Observable<()> {
        return loginUseCase.exe(uid: uid)
    }

    func fetchFavorite() -> Observable<()> {
        return fetchFavoriteUseCase.exe()
    }

    func postFavorite() -> Observable<()> {
        return postFavoriteUC.exe()
    }

    func postForm() -> Observable<()> {
        return postFormUC.exe()
    }

    func fetchMemo() -> Observable<()> {
        return fetchMemoUseCase.exe()
    }

    func postMemo() -> Observable<()> {
        return postMemoUC.exe()
    }

    func postTab() -> Observable<()> {
        return postTabUC.exe()
    }

    func fetchTab() -> Observable<()> {
        return fetchTabUseCase.exe()
    }

    func fetchForm() -> Observable<()> {
        return fetchFormUseCase.exe()
    }
}
