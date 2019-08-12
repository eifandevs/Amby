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
    /// ユースケース
    let closeTabUseCase = CloseTabUseCase()
    let closeTabAllUseCase = CloseTabAllUseCase()
    let copyTabUseCase = CopyTabUseCase()
    let addTabUseCase = AddTabUseCase()

    deinit {
        log.debug("deinit called.")
    }

    /// タブの追加
    func add() {
        addTabUseCase.exe()
    }

    /// スクロールアップ
    func scrollUp() {
        ScrollHandlerUseCase.s.scrollUp()
    }

    /// 自動スクロール
    func autoScroll() {
        ScrollHandlerUseCase.s.autoScroll()
    }

    /// フォーム登録
    func registerForm() {
        FormHandlerUseCase.s.registerForm()
    }

    /// お気に入り切り替え
    func updateFavorite() {
        UpdateFavoriteUseCase().exe()
    }

    /// 現在のタブを削除
    func close() {
        closeTabUseCase.exe()
    }

    /// 現在のタブを削除
    func closeAll() {
        closeTabAllUseCase.exe()
    }

    /// 現在のタブをコピー
    func copy() {
        copyTabUseCase.exe()
    }

    /// 検索開始
    func beginSearching() {
        SearchHandlerUseCase.s.beginAtCircleMenu()
    }

    /// グレップ開始
    func beginGreping() {
        GrepHandlerUseCase.s.begin()
    }

    /// ヒストリーフォワード
    func historyForward() {
        TabHandlerUseCase.s.historyForward()
    }

    /// ヒストリーバック
    func historyBack() {
        TabHandlerUseCase.s.historyBack()
    }
}
