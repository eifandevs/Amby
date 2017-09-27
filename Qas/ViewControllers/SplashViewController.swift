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

class SplashViewController: UIViewController, LTMorphingLabelDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var splashLabel: LTMorphingLabel!
    
    weak var delegate: SplashViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splashLabel.frame.size = CGSize(width: DeviceConst.displaySize.width / 1.2, height: DeviceConst.displaySize.height / 18)
        splashLabel.center = CGPoint(x: DeviceConst.displaySize.width / 2, y: DeviceConst.displaySize.height / 2)
        splashLabel.morphingEffect = .pixelate
        splashLabel.delegate = self
        splashLabel.font = UIFont(name: splashLabel.font.fontName, size: splashLabel.frame.size.height / 2)
        splashLabel.text = "Quick AcceSs browser."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func morphingDidComplete(_ label: LTMorphingLabel) {
        delegate?.splashViewControllerDidEndDrawing()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
