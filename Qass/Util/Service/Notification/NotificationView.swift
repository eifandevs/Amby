//
//  NotificationView.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

/// CustomeToastNotification Class
class NotificationView: UIButton {
    var overlay = UIButton()

    func play() {
        UIView.animate(withDuration: 0.4, animations: {
            self.frame.origin.y -= self.frame.size.height
        }) { finished in
            self.overlay.frame = CGRect(x: 0, y: AppConst.DEVICE.DISPLAY_SIZE.height - (AppConst.BASE_LAYER.THUMBNAIL_SIZE.height * 0.9), width: AppConst.DEVICE.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER.THUMBNAIL_SIZE.height * 0.9)
            self.overlay.backgroundColor = UIColor.clear

            // オーバーレイタップ
            self.overlay.rx.tap
                .subscribe(onNext: { [weak self] in
                    log.eventIn(chain: "rx_tap")
                    guard let `self` = self else { return }
                    self.dissmiss()
                    log.eventOut(chain: "rx_tap")
                })
                .disposed(by: self.rx.disposeBag)

            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.window?.rootViewController?.view.addSubview(self.overlay)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let `self` = self else { return }
                self.overlay.removeFromSuperview()
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.frame.origin.y += self.frame.size.height
                }, completion: { finished in
                    if finished {
                        self.removeFromSuperview()
                    }
                })
            }
        }
    }

    func dissmiss() {
        overlay.removeFromSuperview()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.frame.origin.y += self.frame.size.height
        }, completion: { finished in
            if finished {
                self.removeFromSuperview()
            }
        })
    }
}
