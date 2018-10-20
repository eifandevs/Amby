//
//  PasscodeViewController.swift
//  Qass
//
//  Created by tenma on 2018/10/21.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import SmileLock
import UIKit

class PasscodeViewController: UIViewController {
    @IBOutlet var baseView: UIView!
    @IBOutlet var cancelButton: CornerRadiusButton!
    @IBOutlet var passcodeBaseView: UIView!

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRx()

        let passcodeView = PasswordContainerView.create(withDigit: 6)
        passcodeView.frame = CGRect(x: 0, y: 0, width: passcodeBaseView.bounds.size.width, height: passcodeBaseView.bounds.size.height)
        passcodeBaseView.addSubview(passcodeView)

        cancelButton.backgroundColor = UIColor.ultraOrange
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupRx() {
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: disposeBag)
    }
}
