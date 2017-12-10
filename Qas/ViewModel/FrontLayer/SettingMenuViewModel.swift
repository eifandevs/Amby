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
        sectionItems = [AppConst.SETTING_SECTION_AUTO_SCROLL, AppConst.SETTING_SECTION_DELETE]
        menuItems = [
            [
                OptionMenuItem(type: .slider, sliderAction: { (value: Float) -> Void in
                    log.warning(value)
                    UserDefaults.standard.set(-value, forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL)
                }, defaultValue: -UserDefaults.standard.float(forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL), minValue: Float(-0.07), maxValue: Float(-0.01))
            ],
            [
                OptionMenuItem(title: AppConst.SETTING_TITLE_COMMON_HISTORY, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_COMMON_HISTORY, completion: {
                        CommonHistoryDataModel.s.delete()
                    })
                    return nil
                }),
                OptionMenuItem(title: AppConst.SETTING_TITLE_BOOK_MARK, action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationManager.presentAlert(title: MessageConst.ALERT_DELETE_TITLE, message: MessageConst.ALERT_DELETE_BOOK_MARK, completion: {
                        FavoriteDataModel.s.delete()
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
                        SearchHistoryDataModel.s.delete()
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
                        SearchHistoryDataModel.s.delete()
                        FavoriteDataModel.s.delete()
                        FormDataModel.delete()
                        CacheHelper.deleteCookies()
                        CacheHelper.deleteCaches()
                        ThumbnailDataModel.delete()
                        NotificationCenter.default.post(name: .baseViewModelWillInitialize, object: nil)
                        (UIApplication.shared.delegate as! AppDelegate).initialize()
                    })
                    return nil
                })
            ]
        ]
    }
}
