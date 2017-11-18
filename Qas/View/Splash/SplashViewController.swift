//
//  SplashViewController.swift
//  Qas
//
//  Created by temma on 2017/09/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import LTMorphingLabel

protocol SplashViewControllerDelegate: class {
    func splashViewControllerDidEndDrawing()
}

class SplashViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var splashLabel: LTMorphingLabel!
    
    weak var delegate: SplashViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splashLabel.frame.size = CGSize(width: DeviceConst.DISPLAY_SIZE.width / 1.2, height: DeviceConst.DISPLAY_SIZE.height / 18)
        splashLabel.center = CGPoint(x: DeviceConst.DISPLAY_SIZE.width / 2, y: DeviceConst.DISPLAY_SIZE.height / 2)
        splashLabel.morphingEffect = .scale
        splashLabel.delegate = self
        splashLabel.font = UIFont(name: splashLabel.font.fontName, size: splashLabel.frame.size.height / 2)
        splashLabel.text = "Quick AcceSs browser"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: LTMorphingLabel Delegate
extension SplashViewController: LTMorphingLabelDelegate {
    func morphingDidComplete(_ label: LTMorphingLabel) {
        delegate?.splashViewControllerDidEndDrawing()
    }
}
