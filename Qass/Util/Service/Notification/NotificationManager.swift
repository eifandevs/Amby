//
//  NotificationManager.swift
//  Qas
//
//  Created by temma on 2017/09/19.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

/// 通知マネージャー
class NotificationManager {
    static func presentNotification(message: String) {
        let notificationView = NotificationView(frame: CGRect(x: 0, y: DeviceConst.DISPLAY_SIZE.height, width: DeviceConst.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER_THUMBNAIL_SIZE.height * 0.9))
        notificationView.setTitle(" 　\(message)", for: .normal)
        notificationView.titleLabel?.textColor = UIColor.white
        notificationView.titleLabel?.font = UIFont(name: AppConst.APP_FONT, size: notificationView.frame.size.height / 4)
        notificationView.backgroundColor = UIColor.darkGray
        notificationView.contentHorizontalAlignment = .left
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view.addSubview(notificationView)
        notificationView.play()
    }

    static func presentAlert(title: String, message: String, completion: @escaping (() -> Void)) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: MessageConst.COMMON_OK, style: .default, handler: { (_: UIAlertAction!) -> Void in
            completion()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: MessageConst.COMMON_CANCEL, style: .cancel, handler: { (_: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        Util.foregroundViewController().present(alert, animated: true, completion: nil)
    }

    static func presentActionSheet(title: String, message: String, completion: (() -> Void)?) {
        // styleをActionSheetに設定
        let alertSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)

        // 自分の選択肢を生成
        let action1 = UIAlertAction(title: MessageConst.COMMON_OK, style: UIAlertActionStyle.default, handler: {
            (_: UIAlertAction!) in
            completion?()
        })
        let action2 = UIAlertAction(title: MessageConst.COMMON_CANCEL, style: UIAlertActionStyle.cancel, handler: {
            (_: UIAlertAction!) in
        })

        // アクションを追加.
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)

        Util.foregroundViewController().present(alertSheet, animated: true, completion: nil)
    }
}