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
        sectionItems = [AppConst.SETTING_SECTION_AUTO_SCROLL, AppConst.SETTING_SECTION_HISTORY, AppConst.SETTING_SECTION_DELETE]
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
                OptionMenuItem(title: AppConst.SETTING_TITLE_COMMON_HISTORY, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_COMMON_HISTORY, completion: {
                        CommonHistoryDataModel.s.delete()
                        NotificationCenter.default.post(name: .baseViewModelWillDeleteHistory, object: nil)
                    })
                    return nil
                }),
                OptionMenuItem(title: AppConst.SETTING_TITLE_BOOK_MARK, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_BOOK_MARK, completion: {
                        FavoriteDataModel.delete()
                        NotificationCenter.default.post(name: .headerViewModelWillChangeFavorite, object: nil)
                    })
                    return nil
                }),
                OptionMenuItem(title: AppConst.SETTING_TITLE_FORM_DATA, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_FORM, completion: {
                        FormDataModel.delete()
                    })
                    return nil
                }),
                OptionMenuItem(title: AppConst.SETTING_TITLE_SEARCH_HISTORY, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_SEARCH_HISTORY, completion: {
                        CommonDao.s.deleteAllSearchHistory()
                    })
                    return nil
                }),
                OptionMenuItem(title: AppConst.SETTING_TITLE_COOKIES, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_COOKIES, completion: {
                        CacheHelper.deleteCookies()
                    })
                    return nil
                }),
                OptionMenuItem(title: AppConst.SETTING_TITLE_SITE_DATA, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_SITE_DATA, completion: {
                        CacheHelper.deleteCaches()
                    })
                    return nil
                }),
                OptionMenuItem(title: AppConst.SETTING_TITLE_ALL, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_ALL, completion: {
                        CommonHistoryDataModel.s.delete()
                        PageHistoryDataModel.s.delete()
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
