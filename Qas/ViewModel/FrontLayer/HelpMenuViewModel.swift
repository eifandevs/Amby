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
                OptionMenuItem(title: MessageConst.HELP_HISTORY_SAVE_TITLE, action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = MessageConst.HELP_HISTORY_SAVE_SUBTITLE
                    let message = MessageConst.HELP_HISTORY_SAVE_MESSAGE
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                        ])
                    return nil
                }),
                OptionMenuItem(title: MessageConst.HELP_SEARCH_CLOSE_TITLE, action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = MessageConst.HELP_SEARCH_CLOSE_SUBTITLE
                    let message = MessageConst.HELP_SEARCH_CLOSE_MESSAGE
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                        ])
                    return nil
                }),
                OptionMenuItem(title: MessageConst.HELP_FORM_TITLE, action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = MessageConst.HELP_FORM_SUB_TITLE
                    let message = MessageConst.HELP_FORM_MESSAGE
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                    ])
                    return nil
                }),
                OptionMenuItem(title: MessageConst.HELP_AUTO_SCROLL_TITLE, action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = MessageConst.HELP_AUTO_SCROLL_SUBTITLE
                    let message = MessageConst.HELP_AUTO_SCROLL_MESSAGE
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                    ])
                    return nil
                }),
                OptionMenuItem(title: MessageConst.HELP_TAB_TRANSITION_TITLE, action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = MessageConst.HELP_TAB_TRANSITION_SUBTITLE
                    let message = MessageConst.HELP_TAB_TRANSITION_MESSAGE
                    NotificationCenter.default.post(name: .baseViewControllerWillPresentHelp, object: [
                        self.objectKeySubTitle: subtitle,
                        self.objectKeyMessage : message
                    ])
                    return nil
                }),
                OptionMenuItem(title: MessageConst.HELP_TAB_DELETE_TITLE, action: { [weak self] (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    guard let `self` = self else { return nil }
                    let subtitle = MessageConst.HELP_TAB_DELETE_SUBTITLE
                    let message = MessageConst.HELP_TAB_DELETE_MESSAGE
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
