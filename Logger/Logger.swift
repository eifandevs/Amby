//
//  Logger.swift
//  Logger
//
//  Created by tenma on 2018/08/31.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import SwiftyBeaver

let log = Logger.self

open class Logger: SwiftyBeaver {
    public class func setup() {
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

        #if DEBUG
            log.info("DEBUG BUILD")
        #endif

        #if UT
            log.info("UT BUILD")
        #endif

        #if LOCAL
            log.info("LOCAL BUILD")
        #endif

        #if RELEASE
            log.info("RELEASE BUILD")
        #endif
    }
}
