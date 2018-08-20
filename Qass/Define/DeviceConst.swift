//
//  DeviceDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/09.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

/// 汎用定数構造体
struct DeviceConst {
    static let DEVICE = DEVICE_VALUE()
    struct DEVICE_VALUE {
        let STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.height
        let DISPLAY_SIZE = UIScreen.main.bounds.size
        let CACHES_PATH = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let ASPECT_RATE = UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
    }
}
