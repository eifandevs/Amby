//
//  Logger.swift
//  Model
//
//  Created by tenma on 2018/08/30.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import SwiftyBeaver

class Logger: SwiftyBeaver {
    class func setup() {
        let console = ConsoleDestination() // log to Xcode Console
        let file = FileDestination() // log to default swiftybeaver.log file

        #if DEBUG
        console.minLevel = log.Level.verbose
        file.minLevel = log.Level.verbose
        #else
        console.minLevel = log.Level.error
        file.minLevel = log.Level.error
        #endif

        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"

        log.addDestination(console)
        log.addDestination(file)
    }

    class func eventIn(fileName: String = #file, functionName: String = #function, chain: String = "") {
        let fname = fileName.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        if chain.isEmpty {
            log.verbose("\(fname).\(functionName) >>>")
        } else {
            log.verbose("\(fname).\(functionName).\(chain) >>>")
        }
    }

    class func eventOut(fileName: String = #file, functionName: String = #function, chain: String = "") {
        let fname = fileName.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        if chain.isEmpty {
            log.verbose("\(fname).\(functionName) <<<")
        } else {
            log.verbose("\(fname).\(functionName).\(chain) <<<")
        }
    }
}
