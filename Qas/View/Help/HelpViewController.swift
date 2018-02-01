//
//  HelpViewController.swift
//  Qas
//
//  Created by temma on 2017/08/20.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import VerticalAlignmentLabel
import RxSwift
import RxCocoa
import NSObject_Rx

class HelpViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var closeButton: CornerRadiusButton!
    @IBOutlet weak var messageLabel: VerticalAlignmentLabel!
    @IBOutlet weak var subtitleLabel: VerticalAlignmentLabel!
    
    private var subtitle: String = ""
    private var message: String = ""
    
    convenience init(subtitle: String, message: String) {
        self.init(nibName: R.nib.helpViewController.name, bundle: nil)
        self.subtitle = subtitle
        self.message = message
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        subtitleLabel.text = subtitle
        messageLabel.text = message
        closeButton.backgroundColor = UIColor.brilliantBlue

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
