//
//  DeviceDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/09.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class DeviceDataManager {
    static let shared: DeviceDataManager = DeviceDataManager()
    let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    let displaySize = UIScreen.main.bounds.size
    let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    private init() {
        
    }
}
