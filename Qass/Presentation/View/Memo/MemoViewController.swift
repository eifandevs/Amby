//
//  MemoViewController.swift
//  Qass
//
//  Created by tenma on 2018/10/27.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Model
import RxCocoa
import RxSwift
import UIKit

class MemoViewController: UIViewController {
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var textView: UITextView!

    private var memo: Memo!

    convenience init(memo: Memo) {
        self.init(nibName: R.nib.memoViewController.name, bundle: nil)
        self.memo = memo
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = memo.text
        setupRx()
    }

    private func setupRx() {
        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: rx.disposeBag)
    }
}
