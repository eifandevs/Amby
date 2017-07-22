//
//  SettingMenuViewModel.swift
//  Qas
//
//  Created by User on 2017/06/13.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class SettingMenuViewModel: OptionMenuTableViewModel {
    override init() {
        super.init()
    }
    
    override func setup() {
        sectionItems = ["自動スクロール設定", "データ削除", "初期化"]
        menuItems = [
//            [
//                OptionMenuItem(type: .select,
//                               title: "プライベートモード",
//                               switchAction: { (isOn: Bool) -> () in
//                                UserDefaults.standard.set(isOn ? "true" : "false", forKey: AppConst.privateModeKey)
//                               },
//                               defaultValue: UserDefaults.standard.string(forKey: AppConst.privateModeKey) == "true"),
//            ],
            [
                OptionMenuItem(type: .slider, defaultValue: -UserDefaults.standard.float(forKey: AppConst.autoScrollIntervalKey))
            ],
            [
                OptionMenuItem(title: "閲覧履歴", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    Util.presentAlert(title: "データ削除", message: "閲覧履歴を全て削除します。よろしいですか？", completion: {
                        CommonDao.s.deleteAllCommonHistory()
                    })
                    return nil
                }),
                OptionMenuItem(title: "ブックマーク", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    Util.presentAlert(title: "データ削除", message: "ブックマークを全て削除します。よろしいですか？", completion: {
                        CommonDao.s.deleteAllFavorite()
                        NotificationCenter.default.post(name: .headerViewModelWillChangeFavorite, object: false)
                    })
                    return nil
                }),
                OptionMenuItem(title: "フォームデータ", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    Util.presentAlert(title: "データ削除", message: "フォームデータを全て削除します。よろしいですか？", completion: {
                        CommonDao.s.deleteAllForm()
                    })
                    return nil
                }),
                OptionMenuItem(title: "Cookie", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    Util.presentAlert(title: "データ削除", message: "Cookieデータを全て削除します。よろしいですか？", completion: {
                        CacheHelper.deleteCookies()
                    })
                    return nil
                }),
                OptionMenuItem(title: "サイトデータ", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    Util.presentAlert(title: "データ削除", message: "サイトデータを全て削除します。よろしいですか？", completion: {
                        CacheHelper.deleteCaches()
                    })
                    return nil
                })
            ],
            [
                OptionMenuItem(title: "初期化", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    Util.presentAlert(title: "データ削除", message: "全てのデータを削除し、初期化します。よろしいですか？", completion: {
                        CommonDao.s.deleteAllCommonHistory()
                        CommonDao.s.deleteAllHistory()
                        CommonDao.s.deleteAllFavorite()
                        CommonDao.s.deleteAllForm()
                        CacheHelper.deleteCookies()
                        CacheHelper.deleteCaches()
                        CommonDao.s.deleteAllThumbnail()
                        (UIApplication.shared.delegate as! AppDelegate).initialize()
                    })
                    return nil
                })
            ],
        ]
    }
}
