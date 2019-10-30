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
        getAccessToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        log.debug("deinit called.")
    }

    func getAccessToken() {
        viewModel.getAccessToken().subscribe { [weak self] result in
            switch result {
            case let .success:
                log.debug("success get access token")
                self!.rx_action.onNext(.endDrawing)
            case .error:
                log.error("fail to get access token")
                NotificationService.presentRetryAlert(title: MessageConst.ALERT.COMMON_TITLE, message: MessageConst.ALERT.COMMON_MESSAGE, completion: {
                    self!.getAccessToken()
                })
            }
        }.disposed(by: disposeBag)
    }
}
