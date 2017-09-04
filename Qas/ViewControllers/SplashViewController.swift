//
//  SplashViewController.swift
//  Qas
//
//  Created by temma on 2017/09/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import LTMorphingLabel

class SplashViewController: UIViewController, LTMorphingLabelDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var splashLabel: LTMorphingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splashLabel.morphingEffect = .pixelate
        splashLabel.text = "Quick Access Browser"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
