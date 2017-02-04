//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, EGApplicationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        EGApplication.sharedMyApplication.egDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    internal func screenTouchBegan(touch: UITouch) {
        debugLog("began")
    }
    
    internal func screenTouchMoved(touch: UITouch) {
        debugLog("moved")
    }
    
    internal func screenTouchEnded(touch: UITouch) {
        debugLog("ended")
    }

    internal func screenTouchCancelled(touch: UITouch) {
        debugLog("cancelled")
    }
}

