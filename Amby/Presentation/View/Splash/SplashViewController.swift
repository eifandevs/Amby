//
//  SplashViewController.swift
//  Amby
//
//  Created by temma on 2017/09/04.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

enum SplashViewControllerAction {
    case endDrawing
}

class SplashViewController: UIViewController {
    /// アクション通知用RX
    let rx_action = PublishSubject<SplashViewControllerAction>()

    let viewModel = SplashViewControllerViewModel()

    @IBOutlet var contentView: UIView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        viewModel.getAccessToken().subscribe { result in
//            switch result {
//            case let .success(response):
//                log.debug("success get access token. response: \(response)")
//            case .error:
//                log.error("fail to get access token")
//            }
//        }.disposed(by: disposeBag)
        rx_action.onNext(.endDrawing)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        log.debug("deinit called.")
    }
}
