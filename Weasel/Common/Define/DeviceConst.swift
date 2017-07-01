//
//  DeviceDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/09.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class DeviceConst {
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    static let displaySize = UIScreen.main.bounds.size
    static let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    static let aspectRate = UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
    private init() {
        
    }
}
