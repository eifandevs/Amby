//
//  DeviceDataManager.swift
//  Eiger
//
//  Created by tenma on 2017/02/09.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

/// 汎用定数クラス
final class DeviceConst {
    static let STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.height
    static let DISPLAY_SIZE = UIScreen.main.bounds.size
    static let CACHES_PATH = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    static let ASPECT_RATE = UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
}
