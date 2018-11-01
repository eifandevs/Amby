//
//  NotificationView.swift
//  Qass
//
//  Created by tenma on 2018/10/20.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ToastView: UIView {
    @IBOutlet var baseButton: UIButton!
    @IBOutlet var iconImageView: UIImageView!

    convenience init(frame: CGRect, title: String, isSuccess: Bool) {
        self.init(frame: frame)
        baseButton.setTitle(title, for: .normal)

        if isSuccess {
            iconImageView.image = R.image.notificationCheck()!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            iconImageView.tintColor = UIColor.lightGreen
        } else {
            iconImageView.image = R.image.notificationError()!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            iconImageView.tintColor = UIColor.red
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    deinit {
        log.debug("deinit called.")
    }

    func loadNib() {
        guard let view = Bundle.main.loadNibNamed(R.nib.toastView.name, owner: self, options: nil)?.first as? UIView else { return }
        view.frame = bounds
        baseButton.titleLabel?.font = UIFont(name: AppConst.APP.FONT, size: frame.size.height / 4.5)

        addSubview(view)
    }

    func play() {
        UIView.animate(withDuration: 0.4, animations: {
            self.frame.origin.y -= self.frame.size.height
        }) { _ in
            self.baseButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    log.eventIn(chain: "rx_tap")
                    guard let `self` = self else { return }
                    self.dissmiss()
                    log.eventOut(chain: "rx_tap")
                })
                .disposed(by: self.rx.disposeBag)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let `self` = self else { return }
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.frame.origin.y += self.frame.size.height
                }, completion: { _ in
                    self.removeFromSuperview()
                })
            }
        }
    }

    private func dissmiss() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.frame.origin.y += self.frame.size.height
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
