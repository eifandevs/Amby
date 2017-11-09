//
//  NotificationManager.swift
//  Qas
//
//  Created by temma on 2017/09/19.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class NotificationView: UIButton {
    var overlay = UIButton()

    func play() {
        UIView.animate(withDuration: 0.4, animations: {
            self.frame.origin.y -= self.frame.size.height
        }) { (finished) in
            if finished {
                self.overlay.frame = CGRect(x: 0, y: DeviceConst.displaySize.height - (AppConst.thumbnailSize.height * 0.9), width: DeviceConst.displaySize.width, height: AppConst.thumbnailSize.height * 0.9)
                self.overlay.backgroundColor = UIColor.clear
                self.overlay.addTarget(self, action: #selector(self.onTappedOverlay(_:)), for: .touchDown)
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view.addSubview(self.overlay)

                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    guard let `self` = self else { return }
                    self.overlay.removeFromSuperview()
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                        self.frame.origin.y += self.frame.size.height
                    }, completion: { (finished) in
                        if finished {
                            self.removeFromSuperview()
                        }
                    })                }
            }
        }
    }

    func dissmiss() {
        self.overlay.removeFromSuperview()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.frame.origin.y += self.frame.size.height
        }, completion: { (finished) in
            if finished {
                self.removeFromSuperview()
            }
        })
    }

    @objc func onTappedOverlay(_ sender: AnyObject) {
        dissmiss()
    }
}

class NotificationManager {
    
    static func presentNotification(message: String) {
        let notificationView = NotificationView(frame: CGRect(x: 0, y: DeviceConst.displaySize.height, width: DeviceConst.displaySize.width, height: AppConst.thumbnailSize.height * 0.9))
        notificationView.setTitle(" 　\(message)", for: .normal)
        notificationView.titleLabel?.textColor = UIColor.white
        notificationView.titleLabel?.font = UIFont(name: AppConst.appFont, size: notificationView.frame.size.height / 4)
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
