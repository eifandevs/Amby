//
//  OnceExec.swift
//  Amby
//
//  Created by temma on 2017/07/25.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation

class OnceExec {
    var isExec = false
    func call(onceExec: () -> Void) {
        if !isExec {
            onceExec()
            isExec = true
        }
    }
}
