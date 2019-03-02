//
//  OptionMenuMemoTableViewModel.swift
//  Amby
//
//  Created by tenma on 2018/10/31.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Model
import RxCocoa
import RxSwift

enum OptionMenuMemoTableViewModelAction {
    case reload
}

final class OptionMenuMemoTableViewModel {
    /// アクション通知用RX
    let rx_action = PublishSubject<OptionMenuMemoTableViewModelAction>()

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    init() {
        setupRx()
    }

    func setupRx() {
        // リロード監視
        MemoUseCase.s.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element, case .update = action else { return }
                self.rx_action.onNext(.reload)
            }
            .disposed(by: disposeBag)
    }

    // セル情報
    struct Row {
        let data: Memo
    }

    // セル
    private var rows: [Row] {
        return MemoUseCase.s.select().map { Row(data: $0) }
    }

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_MEMO_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// セル削除
    func removeRow(indexPath: IndexPath) {
        // モデルから削除
        let row = getRow(indexPath: indexPath)
        MemoUseCase.s.delete(memo: row.data)
    }

    /// ロック or アンロック
    func invertLock(memo: Memo) {
        if PasscodeUseCase.s.authentificationChallenge() {
            MemoUseCase.s.invertLock(memo: memo)
        }
    }

    /// お問い合わせ表示
    func openMemo(memo: Memo? = nil) {
        if let memo = memo {
            if memo.isLocked {
                if PasscodeUseCase.s.authentificationChallenge() {
                    MemoUseCase.s.open(memo: memo)
                }
            } else {
                MemoUseCase.s.open(memo: memo)
            }
        } else {
            // 新規作成
            let newMemo = Memo()
            MemoUseCase.s.open(memo: newMemo)
        }
    }
}
