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

final class HeaderViewModel {
    enum Action {
        case updateProgress(progress: CGFloat)
        case updateFavorite(flag: Bool)
        case updateField(text: String)
        case search(forceFlag: Bool)
        case grep
    }

    let rx_action = PublishSubject<Action>()

    /// Observable自動解放
    let disposeBag = DisposeBag()

    init() {
        setupRx()
    }

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }

    private func setupRx() {
        // プログレス更新監視
        ProgressUseCase.s.rx_progressUseCaseDidChangeProgress
            .subscribe { [weak self] progress in
//                log.eventIn(chain: "rx_progressUseCaseDidChangeProgress")
                guard let `self` = self, let progress = progress.element else { return }
                self.rx_action.onNext(Action.updateProgress(progress: progress))
//                log.eventOut(chain: "rx_progressUseCaseDidChangeProgress")
            }
            .disposed(by: disposeBag)

        // お気に入り更新監視
        FavoriteUseCase.s.rx_favoriteUseCaseDidChangeFavorite
            .subscribe { [weak self] flag in
                log.eventIn(chain: "rx_favoriteUseCaseDidChangeFavorite")
                guard let `self` = self, let flag = flag.element else { return }
                self.rx_action.onNext(Action.updateFavorite(flag: flag))
                log.eventOut(chain: "rx_favoriteUseCaseDidChangeFavorite")
            }
            .disposed(by: disposeBag)

        // テキストフィールド更新監視
        ProgressUseCase.s.rx_progressUseCaseDidChangeField
            .subscribe { [weak self] text in
                log.eventIn(chain: "rx_progressUseCaseDidChangeField")
                guard let `self` = self, let text = text.element else { return }
                self.rx_action.onNext(Action.updateField(text: text))
                log.eventOut(chain: "rx_progressUseCaseDidChangeField")
            }
            .disposed(by: disposeBag)

        // 編集開始監視
        SearchUseCase.s.rx_searchUseCaseDidBeginSearching
            .subscribe { [weak self] flag in
                log.eventIn(chain: "rx_searchUseCaseDidBeginSearching")
                guard let `self` = self, let flag = flag.element else { return }
                self.rx_action.onNext(Action.search(forceFlag: flag))
                log.eventOut(chain: "rx_searchUseCaseDidBeginSearching")
            }
            .disposed(by: disposeBag)

        // グレップ開始監視
        GrepUseCase.s.rx_grepUseCaseDidBeginGreping
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_grepUseCaseDidBeginGreping")
                guard let `self` = self else { return }
                self.rx_action.onNext(Action.grep)
                log.eventOut(chain: "rx_grepUseCaseDidBeginGreping")
            }
            .disposed(by: disposeBag)
    }

    // MARK: Public Method

    func historyBack() {
        HistoryUseCase.s.goBack()
    }

    func historyForward() {
        HistoryUseCase.s.goForward()
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
