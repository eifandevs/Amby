//
//  OnceExec.swift
//  Qas
//
//  Created by temma on 2017/07/25.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class OnceExec {
    var isExec = false
    func call(onceExec: ()->()){
        if !isExec {
            onceExec()
            isExec = true
        }
    }
}
