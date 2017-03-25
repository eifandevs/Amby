//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    private var baseLayer: BaseLayer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // レイヤー構造にしたいので、self.viewに対してaddSubViewする(self.view = baseLayerとしない)
        baseLayer = BaseLayer(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size))
        view.addSubview(baseLayer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        baseLayer.stopProgressObserving()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
