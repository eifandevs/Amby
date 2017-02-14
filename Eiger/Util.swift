//
//  Util.swift
//  Eiger
//
//  Created by temma on 2017/02/14.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class Util {
    static let shared: Util = Util()
    private init() {}

    func foregroundViewController() -> UIViewController {
        var vc = UIApplication.shared.keyWindow?.rootViewController;
        while ((vc!.presentedViewController) != nil) {
            vc = vc!.presentedViewController;
        }
        return vc!;
    }
}
