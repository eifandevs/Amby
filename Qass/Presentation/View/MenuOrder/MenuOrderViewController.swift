//
//  MenuOrderViewController.swift
//  Qass
//
//  Created by tenma on 2018/08/20.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class MenuOrderViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: CornerRadiusButton!

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRx()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupRx() {
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
