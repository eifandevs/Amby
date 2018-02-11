//
//  SplashViewController.swift
//  Qas
//
//  Created by temma on 2017/09/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

protocol SplashViewControllerDelegate: class {
    func splashViewControllerDidEndDrawing()
}

class SplashViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    
    weak var delegate: SplashViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.splashViewControllerDidEndDrawing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
