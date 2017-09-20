//
//  NotificationManager.swift
//  Qas
//
//  Created by temma on 2017/09/19.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class NotificationManager {
    
    static func presentNotification(message: String) {
        let notificationView = UILabel(frame: CGRect(x: 0, y: DeviceConst.displaySize.height - (AppConst.thumbnailSize.height * 0.9), width: DeviceConst.displaySize.width, height: AppConst.thumbnailSize.height * 0.9))
        notificationView.textColor = UIColor.white
        notificationView.font = UIFont(name: AppConst.appFont, size: notificationView.frame.size.height / 4)
        notificationView.backgroundColor = UIColor.darkGray
        notificationView.text = " 　\(message)"
        notificationView.textAlignment = .left
        (UIApplication.shared.delegate as! AppDelegate).window?.addSubview(notificationView)
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
