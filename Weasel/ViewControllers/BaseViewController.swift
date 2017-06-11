//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, BaseLayerDelegate, FrontLayerDelegate {
    
    private var baseLayer: BaseLayer! = nil
    private var frontLayer: FrontLayer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // レイヤー構造にしたいので、self.viewに対してaddSubViewする(self.view = baseLayerとしない)
        baseLayer = BaseLayer(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.bounds.size))
        baseLayer.delegate = self
        view.addSubview(baseLayer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: BaseLayer Delegate
    func baseLayerDidInvalidate(direction: EdgeSwipeDirection) {
        frontLayer = FrontLayer(frame: baseLayer.frame)
        frontLayer.swipeDirection = direction
        frontLayer.delegate = self
        view.addSubview(frontLayer)
    }
    
// MARK: FrontLayer Delegate
    func frontLayerDidInvalidate() {
        frontLayer.removeFromSuperview()
        frontLayer = nil
        baseLayer.validateUserInteraction()
    }

}
