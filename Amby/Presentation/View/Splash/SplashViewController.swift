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

    @IBOutlet var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: get accesstoken
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
