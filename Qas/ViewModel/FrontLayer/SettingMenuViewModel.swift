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
        sectionItems = ["自動スクロール設定", "履歴保存期間", "データ削除"]
        menuItems = [
            [
                OptionMenuItem(type: .slider, sliderAction: { (value: Float) -> Void in
                    UserDefaults.standard.set(-value, forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL)
                }, defaultValue: -UserDefaults.standard.float(forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL), minValue: Float(-0.07), maxValue: Float(-0.01))
            ],
            [
                OptionMenuItem(type: .slider, sliderAction: { (value: Float) -> Void in
                    log.warning(value)
                }, defaultValue: Float(UserDefaults.standard.integer(forKey: AppConst.KEY_HISTORY_SAVE_TERM)), minValue: Float(1), maxValue: Float(365))
            ],
            [
                OptionMenuItem(title: "閲覧履歴", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: "データ削除", message: "閲覧履歴を全て削除します。よろしいですか？", completion: {
                        CommonDao.s.deleteAllCommonHistory()
                        NotificationCenter.default.post(name: .baseViewModelWillDeleteHistory, object: nil)
                    })
                    return nil
                }),
                OptionMenuItem(title: "ブックマーク", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: "データ削除", message: "ブックマークを全て削除します。よろしいですか？", completion: {
                        FavoriteDataModel.delete()
                        NotificationCenter.default.post(name: .headerViewModelWillChangeFavorite, object: nil)
                    })
                    return nil
                }),
                OptionMenuItem(title: "フォームデータ", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: "データ削除", message: "フォームデータを全て削除します。よろしいですか？", completion: {
                        FormDataModel.delete()
                    })
                    return nil
                }),
                OptionMenuItem(title: "検索履歴", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: "データ削除", message: "検索履歴を全て削除します。よろしいですか？", completion: {
                        CommonDao.s.deleteAllSearchHistory()
                    })
                    return nil
                }),
                OptionMenuItem(title: "Cookie", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: "データ削除", message: "Cookieデータを全て削除します。よろしいですか？", completion: {
                        CacheHelper.deleteCookies()
                    })
                    return nil
                }),
                OptionMenuItem(title: "サイトデータ", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: "データ削除", message: "サイトデータを全て削除します。よろしいですか？", completion: {
                        CacheHelper.deleteCaches()
                    })
                    return nil
                }),
                OptionMenuItem(title: "全てのデータ", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: "データ削除", message: "全てのデータを削除し、初期化します。よろしいですか？", completion: {
                        CommonDao.s.deleteAllCommonHistory()
                        CommonDao.s.deleteAllHistory()
                        CommonDao.s.deleteAllSearchHistory()
                        FavoriteDataModel.delete()
                        FormDataModel.delete()
                        CacheHelper.deleteCookies()
                        CacheHelper.deleteCaches()
                        CommonDao.s.deleteAllThumbnail()
                        NotificationCenter.default.post(name: .baseViewModelWillInitialize, object: nil)
                        (UIApplication.shared.delegate as! AppDelegate).initialize()
                    })
                    return nil
                })
            ]
        ]
    }
}
