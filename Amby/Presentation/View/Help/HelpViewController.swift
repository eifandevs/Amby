//
//  HelpViewController.swift
//  Amby
//
//  Created by temma on 2017/08/20.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import VerticalAlignmentLabel

class HelpViewController: UIViewController {
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var messageLabel: VerticalAlignmentLabel!
    @IBOutlet var subtitleLabel: VerticalAlignmentLabel!

    private var subtitle: String = ""
    private var message: String = ""

    convenience init(subtitle: String, message: String) {
        self.init(nibName: R.nib.helpViewController.name, bundle: nil)
        self.subtitle = subtitle
        self.message = message
    }

    deinit {
        log.debug("deinit called.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        subtitleLabel.text = subtitle
        messageLabel.text = message

        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
