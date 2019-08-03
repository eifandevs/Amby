//
//  FrontLayerViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/03.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class FrontLayerViewModel {
    deinit {
        log.debug("deinit called.")
    }

    /// タブの追加
    func add() {
        TabUseCase.s.add()
    }

    /// スクロールアップ
    func scrollUp() {
        ScrollUseCase.s.scrollUp()
    }

    /// 自動スクロール
    func autoScroll() {
        ScrollUseCase.s.autoScroll()
    }

    /// フォーム登録
    func registerForm() {
        FormUseCase.s.registerForm()
    }

    /// お気に入り切り替え
    func updateFavorite() {
        UpdateFavoriteUseCase().exe()
    }

    /// 現在のタブを削除
    func close() {
        TabUseCase.s.close()
    }

    /// 現在のタブを削除
    func closeAll() {
        TabUseCase.s.closeAll()
    }

    /// 現在のタブをコピー
    func copy() {
        TabUseCase.s.copy()
    }

    /// 検索開始
    func beginSearching() {
        SearchUseCase.s.beginAtCircleMenu()
    }

    /// グレップ開始
    func beginGreping() {
        GrepUseCase.s.begin()
    }

    /// ヒストリーフォワード
    func historyForward() {
        TabUseCase.s.historyForward()
    }

    /// ヒストリーバック
    func historyBack() {
        TabUseCase.s.historyBack()
    }
}
