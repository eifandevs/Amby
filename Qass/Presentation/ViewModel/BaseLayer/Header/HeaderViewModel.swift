//
//  HeaderViewModel.swift
//  Eiger
//
//  Created by temma on 2017/04/30.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class HeaderViewModel {
    /// プログレス更新通知用RX
    let rx_headerViewModelDidChangeProgress = ProgressUseCase.s.rx_progressUseCaseDidChangeProgress
        .flatMap { progress -> Observable<CGFloat> in
            return Observable.just(progress)
        }
    /// お気に入り変更通知用RX
    let rx_headerViewModelDidChangeFavorite = FavoriteUseCase.s.rx_favoriteUseCaseDidChangeFavorite
        .flatMap { flag -> Observable<Bool> in
            return Observable.just(flag)
        }
    /// テキストフィールド更新通知用RX
    let rx_headerViewModelDidChangeField = ProgressUseCase.s.rx_progressUseCaseDidChangeField
        .flatMap { text -> Observable<String> in
            return Observable.just(text)
        }
    /// 編集開始通知用RX
    let rx_headerViewModelDidbeginSearching = SearchUseCase.s.rx_searchUseCaseDidBeginSearching
        .flatMap { forceEditFlg -> Observable<Bool> in
            return Observable.just(forceEditFlg)
        }

    /// グレップ開始通知用RX
    let rx_headerViewModelDidBeginGreping = GrepUseCase.s.rx_grepUseCaseDidBeginGreping
        .flatMap { _ -> Observable<()> in
            return Observable.just(())
        }

    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public Method

    func historyBack() {
        HistoryUseCase.s.goBack()
    }

    func historyForward() {
        HistoryUseCase.s.goForward()
    }

    func loadRequest(text: String) {
        SearchUseCase.s.load(url: text)
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
