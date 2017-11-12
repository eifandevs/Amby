//
//  HelpMenuViewModel.swift
//  Qas
//
//  Created by temma on 2017/08/20.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class HelpMenuViewModel: OptionMenuTableViewModel {
    private let objectKeySubTitle = "subtitle"
    private let objectKeyMessage = "message"
    override init() {
        super.init()
    }
    
    override func setup() {
        menuItems = [
            [
                OptionMenuItem(title: "フォームについて", action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = "フォームの自動入力"
                    let message = "1. Webページ上のフォームを入力する\n\n2. フォーム登録ボタンを押下する\n\n3. 次回からキーボード表示時に、自動入力ダイアログが表示されます"
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                    ])
                    return nil
                }),
                OptionMenuItem(title: "自動スクロールについて", action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = "スクロール速度の調整"
                    let message = "1. 設定メニューを開く\n\n2. 自動スクロール設定より、変更可能です\n\n3. 自動スクロールは、ページを更新または、再度自動スクロールボタン押下で停止します"
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                    ])
                    return nil
                }),
                OptionMenuItem(title: "タブ間を移動する", action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = "タブの移動パターン"
                    let message = "1. Webページ上を左右にスライドする\n\n2. フッターのサムネイルをタップする"
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                    ])
                    return nil
                }),
                OptionMenuItem(title: "タブを削除する", action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = "タブの削除パターン"
                    let message = "1. ヘッダー右上の削除ボタン(X)をタップする\n\n2. フッターのサムネイルを長押しする"
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                    ])
                    return nil
                }),
                OptionMenuItem(title: "保存情報を個別で削除する", action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = "保存情報の個別削除"
                    let message = "1. メインメニューを開き、一覧を表示する\n\n2. セルを長押しする"
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                    ])
                    return nil
                })
            ]
        ]
    }
}
