//
//  HeaderViewModel.swift
//  Eiger
//
//  Created by temma on 2017/04/30.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

enum HeaderViewModelAction {
    case updateProgress(progress: CGFloat)
    case updateFavorite(isSwitch: Bool)
    case updateCanGoBack(canGoBack: Bool)
    case updateCanGoForward(canGoForward: Bool)
    case updateField(text: String)
    case searchAtMenu
    case searchAtHeader
    case grep
}

final class HeaderViewModel {
    /// アクション通知用RX
    let rx_action = PublishSubject<HeaderViewModelAction>()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    init() {
        setupRx()
    }

    deinit {
        log.debug("deinit called.")
    }

    private func setupRx() {
        // プログレス監視
        ProgressUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .updateProgress(progress):
                    self.rx_action.onNext(.updateProgress(progress: progress))
                case let .updateText(text):
                    self.rx_action.onNext(.updateField(text: text))
                case let .updateCanGoBack(canGoBack):
                    self.rx_action.onNext(.updateCanGoBack(canGoBack: canGoBack))
                case let .updateCanGoForward(canGoForward):
                    self.rx_action.onNext(.updateCanGoForward(canGoForward: canGoForward))
                }
            }
            .disposed(by: disposeBag)

        // お気に入り更新監視
        FavoriteUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case let .update(isSwitch) = action else { return }
                self.rx_action.onNext(.updateFavorite(isSwitch: isSwitch))
            }
            .disposed(by: disposeBag)

        // 編集開始監視
        SearchUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .searchAtMenu:
                    self.rx_action.onNext(.searchAtMenu)
                case .searchAtHeader:
                    self.rx_action.onNext(.searchAtHeader)
                default: break
                }
            }
            .disposed(by: disposeBag)

        // グレップ開始監視
        GrepUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .begin = action else { return }
                self.rx_action.onNext(.grep)
            }
            .disposed(by: disposeBag)
    }

    // MARK: Public Method

    func historyBack() {
        TabUseCase.s.historyBack()
    }

    func historyForward() {
        TabUseCase.s.historyForward()
    }

    func loadRequest(text: String) {
        SearchUseCase.s.load(text: text)
    }

    func grepRequest(word: String) {
        GrepUseCase.s.grep(word: word)
    }

    func updateFavorite() {
        FavoriteUseCase.s.update()
    }

    func remove() {
        TabUseCase.s.remove()
    }
}
