//
//  SplashViewController.swift
//  Qas
//
//  Created by temma on 2017/09/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SplashViewController: UIViewController {
    // スプラッシュ終了通知用RX
    let rx_splashViewControllerDidEndDrawing = PublishSubject<()>()
    
    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rx_splashViewControllerDidEndDrawing.onNext(())
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
