//
//  OptionMenuAppTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model

final class OptionMenuAppTableViewModel {
    // セル情報
    struct Row {
        let cellType: CellType
    }

    enum CellType: Int {
        case opensource
        case policy
        case source
        case report
        case contact

        var title: String {
            switch self {
            case .opensource: return AppConst.APP_INFORMATION.OPENSOURCE
            case .policy: return AppConst.APP_INFORMATION.POLICY
            case .source: return AppConst.APP_INFORMATION.SOURCE
            case .report: return AppConst.APP_INFORMATION.REPORT
            case .contact: return AppConst.APP_INFORMATION.CONTACT
            }
        }
    }

    // セル
    let rows = [
        Row(cellType: .opensource),
        Row(cellType: .policy),
        Row(cellType: .source),
        Row(cellType: .report),
        Row(cellType: .contact)
    ]

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// ソース表示
    func openSource() {
        SourceCodeUseCase.s.open()
    }

    /// ライセンス表示
    func openLicense() {
        OpenSourceUseCase.s.open()
    }

    /// ポリシー表示
    func openPolicy() {
        PolicyUseCase.s.open()
    }

    /// 問題の報告表示
    func openReport() {
        ReportUseCase.s.open()
    }

    /// お問い合わせ表示
    func openContact() {
        ContactUseCase.s.open()
    }
}
