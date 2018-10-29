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
    @IBOutlet var tableView: UITableView!

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            .disposed(by: disposeBag)
    }
}
