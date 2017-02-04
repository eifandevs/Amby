//
//  EGApplication.swift
//  sample
//
//  Created by tenma on 2017/01/30.
//  Copyright © 2017年 tenma. All rights reserved.
//

import Foundation
import UIKit

@objc protocol EGApplicationDelegate {
    func sendEvent(event: UIEvent)
}

@objc(EGApplication) class EGApplication: UIApplication {
    weak var egDelegate: EGApplicationDelegate?
    static let sharedMyApplication = UIApplication.shared as! EGApplication
    
    override func sendEvent(_ event: UIEvent) {
        self.egDelegate?.sendEvent(event: event)
        super.sendEvent(event)
    }
}
