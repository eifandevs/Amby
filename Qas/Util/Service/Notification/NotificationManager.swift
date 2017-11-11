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
    
    static func presentAlert(title: String, message: String, completion: @escaping (() -> ())) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            completion()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        Util.foregroundViewController().present(alert, animated: true, completion: nil)
    }
}
